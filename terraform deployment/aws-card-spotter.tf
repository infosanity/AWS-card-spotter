provider "aws" {
  version = "~> 2.0"
  region  = "eu-west-1"
  profile = "IS-HP-full"
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "role_basicLambdaExecution"{
  role = "${aws_iam_role.iam_for_lambda.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "cardspotter_sns_policy" {
  name = "cardspotter_sns_policy"
  role = "${aws_iam_role.iam_for_lambda.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublishToSNS",
      "Action": [
        "sns:Publish"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sns_topic.card-spotter-sns.arn}"
    },
    {
      "Sid": "CallRekognition",
      "Action": [
        "rekognition:DetectLabels"
      ],
      "Effect": "Allow",
      "Resource": "*"
    },
    {
      "Sid": "AccesSourceBucket",
      "Action": [
        "s3:GetObject*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}",
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_lambda_permission" "allow_bucket" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.func.arn}"
  principal     = "s3.amazonaws.com"
  source_arn    = "${aws_s3_bucket.bucket.arn}"
}

resource "aws_lambda_function" "func" {
  filename      = "AWS-card-spotter_LAMBDA.zip"
  function_name = "AWS-card-spotter"
  role          = "${aws_iam_role.iam_for_lambda.arn}"
  handler       = "AWS-card-spotter_LAMBDA.lambda_handler"
  runtime       = "python3.7"
  environment {
    variables = {
      SNS_topic = "${aws_sns_topic.card-spotter-sns.arn}"
    }
  }
}

resource "aws_s3_bucket" "bucket" {
  bucket = "infosanity-aws-card-spotter-tfbuild"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"

  lambda_function {
    lambda_function_arn = "${aws_lambda_function.func.arn}"
    events              = ["s3:ObjectCreated:*"]
    #filter_prefix       = "AWSLogs/"
    #filter_suffix       = ".log"
  }
}

resource "aws_sns_topic" "card-spotter-sns" {
  name = "AWS-CardSpotter-Distribution"
}
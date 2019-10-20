import json
import boto3

def notify_sns(message):
    """Send results to SNS for further processing."""
    client = boto3.client('sns', "eu-west-1")
    response = client.publish(
        TargetArn="arn:aws:sns:eu-west-1:<<AWS ACCOUNT NUMBER>>:<<SNS TO PUBLISH TO>>",
        Message=json.dumps({'default': json.dumps(message)}),
        MessageStructure='json'
    )
    print(response)

def find_credit_card(bucket, image):
    """Uses AWS Rekognition to aid identification of credit cards in image."""
    print("Analysing %s::%s" % (bucket, image))
    rekognition = boto3.client("rekognition")
    response = rekognition.detect_labels(
        Image={
            "S3Object":{
                "Bucket": bucket,
                "Name": image
            }
        }
    )

    for label in response['Labels']:
        if label['Name'] == "Credit Card":
            print("[%s] Credit Card Identified in %s with %i confidence" % (bucket, image, int(label['Confidence'])))
            notify_sns("[%s] Credit Card Identified in %s with %i confidence" % (bucket, image, int(label['Confidence'])))

def lambda_handler(event, context):
    """Ingress to Lambda function."""
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']
    find_credit_card(bucket, key)
    return {
        'statusCode': 200,
        'body': json.dumps('aws-card-spotter')
    }
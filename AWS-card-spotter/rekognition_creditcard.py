# coding: utf-8
import boto3
from pprint import pprint
bucket = "aws-card-spotter"
images = ["Black-Credit-Card-Mockup.jpg", "CreditCard.png", "credit-card-perspective.jpg"]
rekog = boto3.client("rekognition", "eu-west-1")
response = rekog.detect_labels(
            Image={
                            "S3Object":{
                                                "Bucket": bucket,
                                                                    "Name": images[0]
                                                                                        }
                                                                                                    }
                                                                                                    )
pprint(response)
for label in response['Labels']:
    pprint(label)
    
for label in response['Labels']:
    if label['Name'] =="Credit Card":
        print("Credit Card Identified: %i Confidence" % int(label['Confidence']))
        
    

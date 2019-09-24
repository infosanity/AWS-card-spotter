#!/usr/bin/python3

import boto3
import click

import config

from pprint import pprint

print(config.bucket)

def cli():
    """Testing Rekognition's ability to identify credit cards."""
    rekog = boto3.client("rekognition", "eu-west-1")

    for image in config.images:
        response = rekog.detect_labels(
                    Image={
                        "S3Object":{
                            "Bucket": config.bucket,
                            "Name": image
                            }
                    }
        )

        for label in response['Labels']:
            if label['Name'] =="Credit Card":
                print("[%s] Credit Card Identified in %s: %i Confidence" % (config.bucket, image, int(label['Confidence'])))

    return

if __name__ == "__main__":
    print("Main")
    cli()

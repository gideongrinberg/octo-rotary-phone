#! /usr/bin/env python
import os
import json
import boto3

def create_lambda_function():
    function_name = "ProcessTESSTarget"
    client = boto3.client("lambda")
    image_uri = "116453493772.dkr.ecr.us-east-1.amazonaws.com/gideongrinberg/pipeline:latest"

    try:
        function = client.get_function(FunctionName=function_name)
        exists = True
    except:
        exists = False

    if exists:
        response = client.update_function_code(
            FunctionName=function_name,
            ImageUri=image_uri
        )

        print("Updated lambda function")
    else:
        response = client.create_function(
            FunctionName=function_name,
            PackageType="Image",
            Code={
                "ImageUri": image_uri
            },
            Role="arn:aws:iam::116453493772:role/pipeline_lambda",
            Timeout=600,
            MemorySize=3008,
            Environment={
                "Variables": {
                    "RESULTS_BUCKET": "tess-pipeline-results"
                }
            }
        )
    
    return response["FunctionArn"]

if __name__ == "__main__":
    lambda_arn = create_lambda_function()
    print(f"Deployment completed successfully. Lambda ARN: {lambda_arn}")
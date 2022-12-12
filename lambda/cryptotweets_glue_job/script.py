import boto3

def lambda_handler(event, context):

    client = boto3.client('glue')

    response = client.start_job_run(
        JobName='s3_to_redshift'
    )

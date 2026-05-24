"""
Handler d'auto-remediation S3.

Recoit un evenement EventBridge declenche par un appel CloudTrail
`CreateBucket`. Force le `public access block` sur le bucket nouvellement
cree pour eviter toute exposition publique.

Egalement utilisable hors EventBridge : un payload de test direct avec
`{"detail": {"requestParameters": {"bucketName": "monbucket"}}}`.
"""

import json
import logging
import os

import boto3

LOGGER = logging.getLogger()
LOGGER.setLevel(logging.INFO)

# En LocalStack, les Lambdas doivent appeler localstack via le hostname interne
# `localstack` du reseau Docker, ou via la variable AWS_ENDPOINT_URL injectee
# par le runtime LocalStack. Nous laissons boto3 utiliser sa configuration
# par defaut, mais on tente une variable d'env pour un test direct hors LS.
_endpoint = os.environ.get("AWS_ENDPOINT_URL")  # injecte par LocalStack
if _endpoint:
    s3_client = boto3.client("s3", endpoint_url=_endpoint)
else:
    s3_client = boto3.client("s3")


PUBLIC_ACCESS_BLOCK = {
    "BlockPublicAcls": True,
    "IgnorePublicAcls": True,
    "BlockPublicPolicy": True,
    "RestrictPublicBuckets": True,
}


def _extract_bucket_name(event):
    detail = event.get("detail") or {}
    params = detail.get("requestParameters") or {}
    return params.get("bucketName")


def lambda_handler(event, context):
    LOGGER.info("Received event: %s", json.dumps(event))

    bucket = _extract_bucket_name(event)
    if not bucket:
        LOGGER.warning("No bucketName in event, nothing to do.")
        return {"remediated": None, "reason": "no bucketName in event"}

    LOGGER.info("Enforcing public access block on bucket %s", bucket)
    s3_client.put_public_access_block(
        Bucket=bucket,
        PublicAccessBlockConfiguration=PUBLIC_ACCESS_BLOCK,
    )

    return {
        "remediated": bucket,
        "action": "put-public-access-block",
        "config": PUBLIC_ACCESS_BLOCK,
    }

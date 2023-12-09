import datetime
import logging as logger
from concurrent.futures import ThreadPoolExecutor

import boto3
from dateutil.relativedelta import relativedelta

from src import config


def copy_object(
    s3_resource, source_bucket, destination_bucket, obj_key, destination_prefix
):
    copy_source = {"Bucket": source_bucket, "Key": obj_key}
    destination_key = destination_prefix + obj_key
    logger.info(
        f"Copying {source_bucket}/{obj_key} to {destination_bucket}/{destination_key}"
    )
    s3_resource.meta.client.copy(copy_source, destination_bucket, destination_key)


def lambda_handler(event, context=None):
    cfg = config.load_config("config/main.yml")
    config.configure_logging()

    s3_resource = boto3.resource("s3")
    today = datetime.datetime.now().strftime(cfg.prefix_format)
    destination_prefix = f"{today}/"

    with ThreadPoolExecutor(max_workers=cfg.max_workers) as executor:
        bucket = s3_resource.Bucket(cfg.source_bucket)
        for obj in bucket.objects.all():
            executor.submit(
                copy_object,
                s3_resource,
                cfg.source_bucket,
                cfg.destination_bucket,
                obj.key,
                destination_prefix,
            )

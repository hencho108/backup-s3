import datetime
from concurrent.futures import ThreadPoolExecutor

import boto3
from dateutil.relativedelta import relativedelta


def copy_object(
    s3_resource, source_bucket, destination_bucket, obj_key, destination_prefix
):
    copy_source = {"Bucket": source_bucket, "Key": obj_key}
    destination_key = destination_prefix + obj_key
    print(f"Copying {obj_key} to {destination_key}")
    s3_resource.meta.client.copy(copy_source, destination_bucket, destination_key)


def main(event, context):
    source_bucket = "hendriks-second-brain-dev"
    destination_bucket = "hendriks-second-brain-backup"
    max_workers = 3

    s3_resource = boto3.resource("s3")
    today = datetime.datetime.now().strftime("%Y-%m-%d")
    destination_prefix = f"{today}/"

    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        bucket = s3_resource.Bucket(source_bucket)
        for obj in bucket.objects.all():
            executor.submit(
                copy_object,
                s3_resource,
                source_bucket,
                destination_bucket,
                obj.key,
                destination_prefix,
            )


if __name__ == "__main__":
    main(None, None)

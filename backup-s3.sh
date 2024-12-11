#!/bin/sh

set -e

S3_DEST_DIR=s3-backup

list_buckets() {
    echo $(aws s3api list-buckets \
            --query 'Buckets[].Name' \
            --output text)
}

bucket_region() {
    echo $(aws s3api get-bucket-location \
            --bucket "$1" \
            --query 'LocationConstraint' \
            --output text)
}

for bucket_name in $(list_buckets); do
    echo "Syncing ${bucket_name} bucket"
    aws s3 --region $(bucket_region ${bucket_name}) sync \
        s3://${bucket_name} ${S3_DEST_DIR}/${bucket_name}
done

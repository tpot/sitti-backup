# Terraform Configuration for AkademiGuru Backups

This repository holds the Terraform script and other utilities for backing
up Sitti Patahuddin's AkademiGuru AWS account.

A S3 bucket is created in the `ap-southeast-2` region in SplatMaths AWS account
where copies of everything I thought was worth backing up:

* Contents of all S3 buckets
* Compressed contents of `/var/www/html` where the SERC Academy website is stored
* Compressed `mysqldump` of the database running on the EC2 instance

The files can be read by any IAM user with an attached `AdministratorAccess` or `PowerUserAccess` policy (or specific permissions). To add IAM users only giving
them the least privileges required, add their username to the `AkademiGuruBackupReadOnlyGroup`
IAM group. This can be done from the command line with `awscli` or from the AWS Console.

## Deployment

If a S3 backend has not been deployed for the destination account, run
the following commands to deploy the [ThoughtBot Cloudformation template
to create Terraform state S3 backend](https://github.com/thoughtbot/cloudformation-terraform-state-backend):

```
$ git clone https://github.com/thoughtbot/cloudformation-terraform-state-backend.git
$ cd cloudformation-terraform-state-backend
$ AWS_PROFILE=<your profile name> \
  AWS_REGION=<your deployment region> \
  aws cloudformation deploy \
    --capabilities CAPABILITY_NAMED_IAM \
    --template-file terraform-state-backend.template \
    --stack-name terraform-state-backend
Waiting for changeset to be created..
Waiting for stack create/update to complete
Successfully created/updated stack - terraform-state-backend
```

Initialise the Terraform backend:
```
$ AWS_PROFILE=<your profile> make tf-init
Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
[...]
```

Verify the plan produced by Terraform to deploy the infrastructure:
```
$ AWS_PROFILE=<your profile> AWS_REGION=ap-southeast-2 \
  terraform plan
[...]
```

If that looks OK, deploy the infrastructure:
```
$ AWS_PROFILE=<your profile> AWS_REGION=ap-southeast-2 \
  terraform apply
[...]
```

## Teardown

Follow these steps to destroy the infrastructure for this feature:

1. Manually remove users from the `AkademiGuruBackupReadOnlyGroup` IAM Group:
```
$ AWS_PROFILE=<your profile name> \
  aws iam get-group --group-name AkademiGuruBackupReadOnlyGroup | \
    jq -r .Users[].UserName
test1

$ AWS_PROFILE=<your profile name> \
  aws iam remove-user-from-group \
    --group-name AkademiGuruBackupReadOnlyGroup \
    --user-name test1
```

2. Run `terraform destroy`:
```
$ AWS_PROFILE=<your profile name> AWS_REGION=<your deployment region> \
    terraform destroy
[...]
```

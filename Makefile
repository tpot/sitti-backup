default:
	@echo 'This Makefile not intended to be run with a default target' && exit 1

# Terraform backend configuration
TF_SCRIPT_NAME=akademiguru-backup
TF_BACKEND_ACCOUNT_ID=995898474277
TF_BACKEND_REGION=ap-southeast-2

tf-init:
	terraform init $${TF_MIGRATE_STATE:+-migrate-state} \
		-backend-config="encrypt=true" \
		-backend-config="bucket=terraform-state-$(TF_BACKEND_ACCOUNT_ID)" \
		-backend-config="key=terraform/$(TF_SCRIPT_NAME)/terraform.tfstate" \
		-backend-config="region=$(TF_BACKEND_REGION)" \
		-backend-config="dynamodb_table=terraform-state-$(TF_BACKEND_ACCOUNT_ID)" \
		-backend-config="kms_key_id=alias/terraform-state-$(TF_BACKEND_ACCOUNT_ID)" \
		-backend-config="role_arn=arn:aws:iam::$(TF_BACKEND_ACCOUNT_ID):role/terraform-state-$(TF_BACKEND_ACCOUNT_ID)"

# Backup creation
HOST=ubuntu@ec2-13-211-73-154.ap-southeast-2.compute.amazonaws.com

mysqldump:
	ssh $(HOST) 'sudo mysqldump --protocol=socket -S /var/run/mysqld/mysqld.sock --all-databases | gzip -9c > foo'

varhtml:
	rsync -av $(HOST):/var/www/html/ var-www-html/

mysqldump.sql.gz:
	rsync -av $(HOST):mysqldump.sql.gz .

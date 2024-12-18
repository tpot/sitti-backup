# Provider and backend configuration
provider "aws" {
}

terraform {
  backend "s3" {
  }
}

# Create S3 bucket
resource "aws_s3_bucket" "akademiguru_bucket" {
  bucket = "akademiguru-backup"
}

# IAM group configuration for read-only bucket access
resource "aws_iam_group" "akademiguru_readonly_group" {
  name = "AkademiGuruBackupReadOnlyGroup"
}

data "aws_iam_policy_document" "backup_bucket_readonly_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::akademiguru-backup",
      "arn:aws:s3:::akademiguru-backup/*",
    ]
  }
}

resource "aws_iam_policy" "backup_bucket_readonly_policy" {
  name        = "AkademiGuruBackupReadOnlyPolicy"
  description = "Read-only access to Akademi Guru backup bucket"
  policy      = data.aws_iam_policy_document.backup_bucket_readonly_policy.json
}

resource "aws_iam_group_policy_attachment" "backup_bucket_policy_attachment" {
  group      = aws_iam_group.akademiguru_readonly_group.name
  policy_arn = aws_iam_policy.backup_bucket_readonly_policy.arn
}

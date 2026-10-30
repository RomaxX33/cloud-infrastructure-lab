data "aws_caller_identity" "current" {}

resource "aws_s3_bucket" "storage" {
  bucket = var.bucket_name

  lifecycle {
    prevent_destroy = true
  }

  #checkov:skip=CKV2_AWS_62:Event notifications are outside the scope of this storage infrastructure.
  #checkov:skip=CKV_AWS_144:Cross-region replication is not required for this single-region lab.
}

resource "aws_s3_bucket_public_access_block" "storage" {
  bucket = aws_s3_bucket.storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "storage" {
  bucket = aws_s3_bucket.storage.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = "alias/aws/s3"
    }

    bucket_key_enabled = true
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "storage" {
  bucket = aws_s3_bucket.storage.id

  depends_on = [
    aws_s3_bucket_versioning.storage
  ]

  rule {
    id     = "expire-noncurrent-versions"
    status = "Enabled"

    filter {}

    abort_incomplete_multipart_upload {

      days_after_initiation = 7

    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

resource "aws_s3_bucket" "access_logs" {
  bucket = "${substr(var.bucket_name, 0, 51)}-access-logs"

  lifecycle {
    prevent_destroy = true
  }

  #checkov:skip=CKV_AWS_18:A logging destination cannot log access to itself.
  #checkov:skip=CKV_AWS_145:AWS S3 server access log destinations require SSE-S3 encryption.
  #checkov:skip=CKV_AWS_144:Cross-region replication is not required for this single-region lab.
  #checkov:skip=CKV2_AWS_62:Event notifications are outside the scope of this storage infrastructure.
}

resource "aws_s3_bucket_public_access_block" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id

  depends_on = [
    aws_s3_bucket_versioning.access_logs
  ]

  rule {
    id     = "expire-access-logs"
    status = "Enabled"

    filter {}

    expiration {
      days = 365
    }

    abort_incomplete_multipart_upload {

      days_after_initiation = 7

    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

data "aws_iam_policy_document" "access_logs" {
  statement {
    sid    = "AllowS3ServerAccessLogDelivery"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    actions = [
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.access_logs.arn}/logs/*"
    ]

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.storage.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = aws_s3_bucket.access_logs.id
  policy = data.aws_iam_policy_document.access_logs.json
}

resource "aws_s3_bucket_logging" "storage" {
  bucket = aws_s3_bucket.storage.id

  target_bucket = aws_s3_bucket.access_logs.id
  target_prefix = "logs/"

  depends_on = [
    aws_s3_bucket_policy.access_logs
  ]
}

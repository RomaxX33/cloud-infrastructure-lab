output "s3_bucket_name" {
  description = "Name of the private S3 bucket."
  value       = aws_s3_bucket.storage.bucket
}

output "aws_region" {
  description = "AWS region used by the provider."
  value       = var.aws_region
}

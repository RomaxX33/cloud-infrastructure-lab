variable "aws_region" {
  description = "AWS region where the infrastructure will be deployed."
  type        = string
  default     = "eu-west-1"
}

variable "environment" {
  description = "Deployment environment."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging or prod."
  }
}

variable "bucket_name" {
  description = "Globally unique name for the S3 bucket."
  type        = string

  validation {
    condition     = length(var.bucket_name) >= 3 && length(var.bucket_name) <= 63
    error_message = "The bucket name must contain between 3 and 63 characters."
  }
}

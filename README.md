# Cloud Infrastructure Lab

Infrastructure-as-Code portfolio project using Terraform and AWS.

## Goals

- Define AWS infrastructure declaratively with Terraform.
- Keep S3 buckets private by blocking public access.
- Encrypt stored data at rest.
- Enable versioning and lifecycle management.
- Centralize S3 server access logs in a separate bucket.
- Validate Terraform and scan security controls automatically with GitHub Actions.

## Architecture

The project defines two S3 buckets in the AWS region configured by `aws_region` (default: `eu-west-1`, Ireland).

### Main storage bucket

- Public access blocked at bucket level.
- Server-side encryption using AWS KMS (`aws:kms`, AWS-managed S3 key).
- S3 Bucket Key enabled.
- Versioning enabled.
- Server access logging enabled.
- Noncurrent object versions expire after 90 days.
- Incomplete multipart uploads are aborted after 7 days.
- Terraform `prevent_destroy` protection enabled.

### Access logs bucket

- Receives server access logs from the main bucket under the `logs/` prefix.
- Public access blocked at bucket level.
- Server-side encryption using SSE-S3 (`AES256`).
- Versioning enabled.
- Current log objects expire after 365 days.
- Noncurrent versions expire after 90 days.
- Incomplete multipart uploads are aborted after 7 days.
- Terraform `prevent_destroy` protection enabled.
- Bucket policy restricts log delivery to the S3 logging service and the source account/bucket.

## Requirements

- Terraform >= 1.6.0
- Git
- Python 3
- AWS credentials only when planning or deploying against AWS

## Validate locally

Run these commands in PowerShell:

- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`

Run the security scan with Checkov 3.4.0.

**On Windows:**

1. Create the environment: `python -m venv .venv-checkov`
2. Install Checkov: `.\.venv-checkov\Scripts\python.exe -m pip install checkov==3.4.0`
3. Run the scan: `.\.venv-checkov\Scripts\python.exe .\.venv-checkov\Scripts\checkov --directory . --framework terraform --output cli`

**On Linux:**

1. Create the environment: `python3 -m venv .venv-checkov`
2. Install Checkov: `.venv-checkov/bin/python -m pip install checkov==3.4.0`
3. Run the scan: `.venv-checkov/bin/checkov --directory . --framework terraform --output cli`

These checks validate the configuration locally. They do not deploy AWS resources.

## GitHub Actions

The workflow in `.github/workflows/terraform.yml` runs on:

- Pushes to `master`.
- Pull requests targeting `master`.
- Manual workflow dispatch.

It performs Terraform formatting and validation, followed by a Checkov security scan.

The workflow does not deploy infrastructure.

## Configure a future deployment

Create a local file named `terraform.tfvars` with the following contents. This file is excluded from Git by `.gitignore`.

- `bucket_name = "replace-with-a-globally-unique-name"`
- `aws_region = "eu-west-1"`
- `environment = "dev"`

Replace the example bucket name with a globally unique name before deployment.

Do not commit real credentials, access keys, tokens, Terraform state files, or local plans.

Before deployment, configure AWS credentials securely, review the Terraform plan, and understand the potential costs.

## Security decisions and scope

- Both buckets block public access.
- The main bucket uses AWS KMS encryption.
- The access logs bucket uses SSE-S3, as required for an S3 server access logging destination.
- Both buckets have versioning and lifecycle rules.
- The main bucket's access logs are delivered to a separate bucket.
- Cross-region replication is outside the scope of this single-region lab.
- Event notifications are outside the current scope.
- The access logs bucket does not log access to itself.
- Terraform `prevent_destroy` helps protect both buckets against accidental Terraform destruction.

The Checkov scan contains documented exceptions for the controls intentionally outside this project's scope.

## Cost considerations

Local validation and security scanning do not create AWS resources.

A real deployment may incur charges for S3 storage, requests, logging, and KMS usage. Review AWS pricing and the Terraform plan before deployment.

## Status

Terraform infrastructure definition, local validation, security scanning, and GitHub Actions CI are configured.

No AWS resources have been deployed or live-verified. Deployment and live AWS verification remain separate future tasks.

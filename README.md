# Cloud Infrastructure Lab

Infrastructure-as-Code portfolio project using Terraform and AWS.

## Goals

- Define AWS infrastructure declaratively with Terraform.
- Keep S3 storage private by blocking public access.
- Enable server-side encryption and object versioning.
- Validate Terraform configuration automatically with GitHub Actions.
- Document reproducible commands and security decisions.

## Architecture

The project defines one S3 bucket with:

- Public access blocked.
- Server-side encryption using AES-256.
- Versioning enabled.
- Terraform destruction protection.

The AWS provider region defaults to `eu-west-1` (Ireland).

## Requirements

- Terraform >= 1.6.0
- Git
- AWS credentials only when planning or deploying against AWS

## Validate locally

Run these commands in PowerShell:

```powershell
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

These commands prepare and validate the configuration. They do not deploy AWS resources.

## Configure a future deployment

Create a local file named `terraform.tfvars` with the following contents. This file is excluded from Git by `.gitignore`.

```hcl
bucket_name = "replace-with-a-globally-unique-name"
aws_region  = "eu-west-1"
environment = "dev"
```

Replace the example bucket name with a globally unique name before deployment.

Do not commit real credentials, access keys, tokens, or state files.

Before deployment, configure AWS credentials securely, review the plan, and understand the potential costs.

## Security decisions

- Public S3 access is blocked.
- Server-side encryption is enabled.
- Versioning is enabled for recovery from accidental changes.
- Terraform's `prevent_destroy` lifecycle rule protects against accidental Terraform destruction.
- GitHub Actions validates the configuration without deploying resources.

## Cost considerations

No resources are created by the local validation commands. A real deployment may incur AWS charges, including storage and requests. Review AWS pricing and remove resources safely when they are no longer needed.

## Status

Initial infrastructure definition and automated validation. Deployment and live AWS verification are separate future tasks.

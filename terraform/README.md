# Terraform Workflows (Temporary Dummy Setup)

This repository currently uses placeholder Terraform configurations so that CI/CD workflows can run `init`, `validate`, and `plan` without touching AWS resources. Each environment (`dev`, `staging`, `prod`) defines a simple `null_resource` with helpful TODO notes.

## Prerequisites

- Terraform `>= 1.4.0`
- Access to this repository (no cloud credentials required yet)

## Quickstart

```bash
# Run fmt/validate/plan for every environment
./scripts/terraform_dummy_init.sh

# Or run manually for a single environment
terraform -chdir=terraform/environments/dev init -backend=false
terraform -chdir=terraform/environments/dev validate
terraform -chdir=terraform/environments/dev plan -lock=false -input=false
```

## Next Steps

- Replace the placeholder resources with real networking, EKS, ECR, and add a backend configuration.
- Wire AWS credentials into the GitHub Actions workflows and local environment before enabling real plans/applies.
- Remove the `-backend=false` and `-lock=false` flags once a remote backend is configured.

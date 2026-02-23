# Healthcare Infrastructure - Terraform

EKS-based infrastructure on AWS (ap-south-1) using Terraform workspaces for environment isolation.

## Architecture

Each Terraform workspace (`dev`, `staging`, `prod`) creates a fully isolated stack:

```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.1.0/24, 10.0.2.0/24) - ap-south-1a, ap-south-1b
├── Private Subnets (10.0.11.0/24, 10.0.12.0/24) - ap-south-1a, ap-south-1b
├── Internet Gateway
├── NAT Gateway (single, in public-a)
├── Route Tables (public → IGW, private → NAT)
├── Security Groups (cluster SG, node SG)
├── IAM Roles (cluster role, node role)
└── EKS Cluster
    └── Managed Node Group (private subnets)
```

## What Gets Deployed

| Module | Resources | Count |
|--------|-----------|-------|
| **VPC** | VPC, 4 subnets, IGW, NAT GW, EIP, 2 route tables, 2 routes, 4 route table associations | 16 |
| **IAM** | EKS cluster role, node role, 4 managed policy attachments | 6 |
| **Security Groups** | Cluster SG, node SG, 6 security group rules | 8 |
| **EKS** | EKS cluster, managed node group, access entry + policy for caller | 4 |
| **Total** | | **~34** |

## Workspace to the Cluster Mapping

| Workspace | Cluster Name | State Key |
|-----------|-------------|-----------|
| `dev` | `healthcare-eks-dev` | `env:/dev/infra/terraform.tfstate` |
| `staging` | `healthcare-eks-staging` | `env:/staging/infra/terraform.tfstate` |
| `prod` | `healthcare-eks-prod` | `env:/prod/infra/terraform.tfstate` |

## Inputs

Root-level variables (set via `-var-file`):

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `node_instance_types` | `list(string)` | `["t3.medium"]` | EC2 instance types for worker nodes |
| `node_desired_size` | `number` | `2` | Desired number of worker nodes |
| `node_min_size` | `number` | `1` | Minimum number of worker nodes |
| `node_max_size` | `number` | `3` | Maximum number of worker nodes |

### Per-Environment Defaults

| Environment | Instance Type | Desired | Min | Max |
|-------------|--------------|---------|-----|-----|
| dev | t3.medium | 2 | 1 | 3 |
| staging | t3.medium | 2 | 2 | 4 |
| prod | t3.large | 3 | 3 | 6 |

## Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | ID of the created VPC |
| `cluster_name` | Name of the EKS cluster (e.g., `healthcare-eks-dev`) |
| `cluster_endpoint` | EKS Kubernetes API server endpoint |
| `kubeconfig_command` | `aws eks update-kubeconfig` command to configure kubectl |

## Prerequisites

- Terraform >= 1.4.0
- AWS CLI configured (`aws configure`)
- `kubectl` installed

## Steps to Deploy

### 1. Bootstrap the S3 State Bucket (one-time)

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

This creates the S3 bucket (`vikas-healthcare-tf-state-2026-xyz123`) with versioning, encryption, and public access block. The bootstrap state is stored locally.

### 2. Deploy Infrastructure

```bash
cd terraform

# Initialize with S3 backend
terraform init

# Create and select workspace
terraform workspace new dev        # first time
terraform workspace select dev     # subsequent runs

# Plan and apply with environment-specific sizing
terraform plan -var-file=environments/dev.tfvars
terraform apply -var-file=environments/dev.tfvars
```

EKS cluster creation takes ~15-20 minutes.

### 3. Connect to the Cluster

```bash
aws eks update-kubeconfig --region ap-south-1 --name healthcare-eks-dev
kubectl get nodes
```

### 4. Deploy to Other Environments

```bash
terraform workspace new staging
terraform apply -var-file=environments/staging.tfvars

terraform workspace new prod
terraform apply -var-file=environments/prod.tfvars
```

## Verification

```bash
# Check cluster is active
aws eks describe-cluster --name healthcare-eks-dev --region ap-south-1 --query 'cluster.status'

# Configure kubectl
aws eks update-kubeconfig --region ap-south-1 --name healthcare-eks-dev

# Verify nodes are ready
kubectl get nodes

# Verify system pods
kubectl get pods -n kube-system
```

## Teardown

```bash
# Destroy a specific environment
terraform workspace select dev
terraform destroy -var-file=environments/dev.tfvars

# Destroy the state bucket (after all environments are destroyed)
cd terraform/bootstrap
terraform destroy
```

## Directory Structure

```
terraform/
├── backend.tf                      # S3 backend configuration
├── providers.tf                    # AWS provider (ap-south-1)
├── versions.tf                     # Terraform and provider version constraints
├── variables.tf                    # Root input variables (node sizing)
├── outputs.tf                      # Root outputs
├── main.tf                         # Module wiring
├── bootstrap/                      # One-time S3 bucket setup (local state)
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   ├── versions.tf
│   └── outputs.tf
├── environments/                   # Per-environment variable overrides
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── modules/
    ├── vpc/                        # VPC, subnets, IGW, NAT GW, route tables
    ├── iam/                        # EKS cluster and node IAM roles
    ├── security-group/             # Cluster and node security groups
    └── eks/                        # EKS cluster and managed node group
```

## CI/CD Pipelines

| Pipeline | Trigger | Action |
|----------|---------|--------|
| `pr-ci.yml` | Pull request | `terraform fmt` + `validate` + `plan` all envs |
| `infra.yml` | `terraform/**` changes on main, or manual dispatch | `plan` + `apply` per workspace |
| `main-dev-qualify.yml` | App changes on main | Build, deploy to dev, qualify, promote to staging |
| `promote-prod.yml` | Manual `workflow_dispatch` | Deploy to prod cluster |

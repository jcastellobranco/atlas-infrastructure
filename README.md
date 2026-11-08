# ATLAS Infrastructure

Infrastructure-as-code scaffold for the integrated ATLAS AI platform on AWS ECS Fargate + RDS PostgreSQL 17.

## Components

- Two-AZ VPC with public ALB and private ECS/RDS subnets; one NAT Gateway (development cost/availability trade-off).
- ECS Fargate services: `api`, `frontend`, `worker`, `agent`, `rag`, `evaluation`.
- Private PostgreSQL RDS, managed master password, backups and deletion protection.
- ECR image repositories, CloudWatch logs, internal Cloud Map discovery.
- GitHub Actions: offline Terraform validation, manual AWS plan, manually approved apply, manually approved ECS deployment.

## Repository layout

- `terraform/environments/dev`: Terraform root module, examples and S3 backend.
- `terraform/modules/platform`: AWS networking, ALB, ECS, RDS and ECR.
- `.github/workflows`: Terraform validation, plan, apply and ECS deployment.
- `docs/BOOTSTRAP.md`: AWS/GitHub setup and prerequisites.
- `docs/OPERATIONS.md`: rollout, recovery, observability and security.

## Quick start (validation only)

```bash
cd terraform/environments/dev
terraform init -backend=false
terraform validate
```

**No AWS resources have been provisioned.** Do not run `terraform apply` yet: service-specific secrets, IAM permissions, image builds, migrations, service health and network policies require completion. Terraform will create billable services. Production GitHub environment must have required reviewers and AWS OIDC role restricted to the repository.

The current Terraform is a **starting scaffold, not a production-ready deployment**. It intentionally does not create a broadly privileged GitHub IAM role. See [bootstrap guide](docs/BOOTSTRAP.md).

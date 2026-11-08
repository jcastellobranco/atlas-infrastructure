# Bootstrap and guardrails

1. Create an S3 bucket for Terraform state with versioning, encryption and restricted access. Configure state locking via S3 lockfile. Do not commit state files.
2. Create a GitHub Actions OIDC identity provider in AWS and a tightly scoped deployment role with trust restricted to `repo:jcastellobranco/atlas-infrastructure:environment:production`. Restrict IAM permissions to required AWS resources.
3. Configure GitHub environment `production` with required reviewers, protected branch restrictions and variables `AWS_ROLE_ARN`, `AWS_REGION`, `TF_STATE_BUCKET`, `TF_STATE_KEY`, `ECS_CLUSTER`, `ECS_SERVICE_PREFIX`.
4. Provision ACM certificate and DNS records before enabling HTTPS listener.
5. Build and push pinned container images for all six services; replace example digest references.
6. Review `terraform plan` and costs before manually approving apply. **Never use production apply for experimentation.**
7. Integrate runtime secrets from AWS Secrets Manager into ECS task definitions, implement DB migration job, and validate network connectivity and application health before deploying.

**Warning:** Terraform scaffold is not production-ready. The task definitions currently omit required service-specific secrets and environment settings. Applying now may create billable AWS resources and unhealthy services.

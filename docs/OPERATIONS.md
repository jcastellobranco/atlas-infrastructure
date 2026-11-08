# Operations

## Deployment
Run CI in each application repository; publish immutable ECR image digests; register a reviewed ECS task definition revision; use manual `deploy.yml` to update one service at a time. Keep Terraform ownership of infrastructure and deployment ownership of task revision updates separate.

## Security
Never store DB credentials, JWT secrets, API keys, or RAG service keys in GitHub code, Terraform variables, or task-definition plaintext. Use AWS Secrets Manager and task-specific least-privilege IAM roles. RDS is private; API and frontend alone should be reachable through ALB. Review and tighten east-west security group rules.

## Recovery
Maintain RDS automated backups, test point-in-time restore, retain immutable image digests, and redeploy the previous task revision for rollback. Document DB migration compatibility before rollbacks.

## Observability
Use CloudWatch logs and metrics, alarms for ECS task failures, ALB 5xx, RDS CPU/storage/connections and queue latency. Propagate trace IDs across ATLAS API, worker, Multi-Agent, RAG and Evaluation.

## Cost
Fargate, ALB, NAT Gateway, RDS, logs and public IPv4 can incur costs even with little traffic. Set AWS Budgets alarms and avoid apply until ready.

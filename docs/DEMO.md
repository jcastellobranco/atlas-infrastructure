# ATLAS demo — low-cost profile

## Architecture and cost

The demo Terraform root is intentionally **independent** of the ECS/RDS environment. It provisions **one EC2 t3.small** with a 30 GB gp3 EBS root volume, public IPv4, minimal networking and SSM access. **No NAT Gateway, ALB, ECS Fargate, or RDS** is created. PostgreSQL and pgvector run in local Docker containers. This is an experimental single-node demo, not production HA. Expect EC2, EBS, public IPv4, data transfer and possibly SSM-related charges; the VM is billable while running, even if the app is stopped. A t3.small has **2 GiB RAM** and cannot reliably run all ATLAS services simultaneously. Use a larger instance, swap and selective services only after testing, or run the full stack locally at no AWS infrastructure cost.

## Start with zero AWS spend (recommended)

Clone sibling repositories into the same parent directory. From `ai-inference-platform`:

```bash
export JWT_SECRET='replace-with-strong-random-secret'
export RAG_DB_OWNER_PASSWORD='replace-with-random-secret'
export RAG_API_KEY='replace-with-random-secret'
export EVAL_API_KEY='replace-with-random-secret'
export ATLAS_AGENT_SERVICE_KEY='replace-with-strong-random-secret'
docker compose -f docker-compose.fullstack.yml -f docker-compose.integrated.yml -f docker-compose.agents.yml -f ../atlas-infrastructure/deploy/demo/compose.demo.yml config
docker compose -f docker-compose.fullstack.yml -f docker-compose.integrated.yml -f docker-compose.agents.yml -f ../atlas-infrastructure/deploy/demo/compose.demo.yml up -d --build
```

This runs the integrated demo with local databases. The override adds CPU/memory caps; it **does not** make the full stack fit on a 2 GiB instance. The frontend is at localhost:8080. Do not expose the default demo HTTP endpoint publicly without TLS and authentication. The sample local database passwords are development-only.

## Optional EC2 host (not an automatic deployment)

```bash
cd terraform/environments/demo
terraform init -backend=false
terraform validate
# Configure a private S3 backend and restrict allowed_http_cidr before applying.
```

EC2 user data installs Docker and Git, but **does not deploy ATLAS** or install the Compose plugin. Use SSM Session Manager to administer the instance; install the Compose plugin, provision the sibling checkouts and environment secrets separately. No inbound SSH port is opened. For real remote access, configure TLS and a domain or use an authenticated tunnel; do not expose port 8080 broadly.

## Cost controls

Set AWS Budgets alarms. To stop compute charges, stop the instance (EBS and public IPv4 allocation rules may still incur charges); to remove resources, use `terraform destroy` after backing up data. A single EC2 is not a substitute for the full ECS production architecture.

## Production

The separate `terraform/environments/dev` root is the ECS/RDS reference architecture. It remains unchanged by this demo profile.

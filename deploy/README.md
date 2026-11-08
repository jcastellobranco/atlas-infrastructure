# Deployment

`deploy.yml` updates an existing ECS service to an existing, reviewed task-definition ARN. It does not build images or register new task definitions.

Required before deployment: service-specific ECS environment and Secrets Manager configuration, migrations, image digests, health checks, DNS and IAM permissions. This scaffold does not perform those steps automatically.

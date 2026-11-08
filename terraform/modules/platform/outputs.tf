output "cluster_name" { value = aws_ecs_cluster.this.name }
output "alb_dns_name" { value = aws_lb.this.dns_name }
output "ecr_repositories" { value = { for k, v in aws_ecr_repository.services : k => v.repository_url } }
output "rds_endpoint" { value = aws_db_instance.this.address }

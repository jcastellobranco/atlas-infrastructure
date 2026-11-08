locals {
  service_ports = { api = 8000, frontend = 3000, worker = 8000, agent = 8000, rag = 8000, evaluation = 8000 }
  services = toset(keys(local.service_ports))
  public_services = toset(["api", "frontend"])
}
data "aws_region" "current" {}
resource "aws_ecr_repository" "services" {
  for_each = local.services
  name = "${var.name}-${each.key}"
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration { scan_on_push = true }
  encryption_configuration { encryption_type = "AES256" }
}
resource "aws_cloudwatch_log_group" "services" {
  for_each = local.services
  name = "/ecs/${var.name}/${each.key}"
  retention_in_days = 30
}
resource "aws_ecs_cluster" "this" {
  name = var.name
  setting { name = "containerInsights"; value = "enabled" }
}
resource "aws_iam_role" "execution" {
  name = "${var.name}-ecs-execution"
  assume_role_policy = jsonencode({ Version = "2012-10-17", Statement = [{ Effect = "Allow", Principal = { Service = "ecs-tasks.amazonaws.com" }, Action = "sts:AssumeRole" }] })
}
resource "aws_iam_role_policy_attachment" "execution" {
  role = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role" "task" {
  name = "${var.name}-ecs-task"
  assume_role_policy = aws_iam_role.execution.assume_role_policy
}
resource "aws_service_discovery_private_dns_namespace" "this" {
  name = "${var.name}.internal"
  vpc = aws_vpc.this.id
}
resource "aws_service_discovery_service" "services" {
  for_each = local.services
  name = each.key
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.this.id
    dns_records { ttl = 10; type = "A" }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config { failure_threshold = 1 }
}
resource "aws_ecs_task_definition" "services" {
  for_each = local.services
  family = "${var.name}-${each.key}"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu = each.key == "worker" ? 1024 : 512
  memory = each.key == "worker" ? 2048 : 1024
  execution_role_arn = aws_iam_role.execution.arn
  task_role_arn = aws_iam_role.task.arn
  container_definitions = jsonencode([{
    name = each.key
    image = var.image_uris[each.key]
    essential = true
    portMappings = [{ containerPort = local.service_ports[each.key], protocol = "tcp" }]
    environment = [
      { name = "AWS_REGION", value = data.aws_region.current.name },
      { name = "ATLAS_ENV", value = var.name }
    ]
    logConfiguration = { logDriver = "awslogs", options = {
      "awslogs-group" = aws_cloudwatch_log_group.services[each.key].name,
      "awslogs-region" = data.aws_region.current.name,
      "awslogs-stream-prefix" = each.key
    } }
  }])
}
resource "aws_ecs_service" "services" {
  for_each = local.services
  name = "${var.name}-${each.key}"
  cluster = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.services[each.key].arn
  desired_count = 1
  launch_type = "FARGATE"
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent = 200
  network_configuration {
    subnets = aws_subnet.private[*].id
    security_groups = [aws_security_group.tasks.id]
    assign_public_ip = false
  }
  dynamic "load_balancer" {
    for_each = contains(local.public_services, each.key) ? [each.key] : []
    content {
      target_group_arn = aws_lb_target_group.public[load_balancer.value].arn
      container_name = each.key
      container_port = local.service_ports[each.key]
    }
  }
  service_registries { registry_arn = aws_service_discovery_service.services[each.key].arn }
  lifecycle { ignore_changes = [task_definition] }
  depends_on = [aws_lb_listener.https]
}

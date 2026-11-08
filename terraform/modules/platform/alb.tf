resource "aws_lb" "this" {
  name = substr(var.name, 0, 32)
  load_balancer_type = "application"
  internal = false
  subnets = aws_subnet.public[*].id
  security_groups = [aws_security_group.alb.id]
  drop_invalid_header_fields = true
}
resource "aws_lb_target_group" "public" {
  for_each = toset(["api", "frontend"])
  name = substr("${var.name}-${each.key}", 0, 32)
  port = local.service_ports[each.key]
  protocol = "HTTP"
  target_type = "ip"
  vpc_id = aws_vpc.this.id
  health_check {
    path = each.key == "api" ? "/health/live" : "/"
    matcher = "200-399"
    healthy_threshold = 2
    unhealthy_threshold = 3
  }
}
resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn = var.certificate_arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.public["frontend"].arn
  }
}
resource "aws_lb_listener_rule" "api" {
  listener_arn = aws_lb_listener.https.arn
  priority = 10
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.public["api"].arn
  }
  condition { path_pattern { values = ["/v1/*", "/health/*", "/api/*"] } }
}

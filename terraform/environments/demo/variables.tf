variable "aws_region" { type = string; default = "us-east-1" }
variable "instance_type" { type = string; default = "t3.small" }
variable "allowed_http_cidr" {
  type = string
  description = "Trusted IPv4 CIDR allowed to access demo HTTP (e.g. your public IP /32). Never set to 0.0.0.0/0 for a private demo."
  validation {
    condition = can(cidrhost(var.allowed_http_cidr, 0)) && var.allowed_http_cidr != "0.0.0.0/0"
    error_message = "Set a valid restricted CIDR, not 0.0.0.0/0."
  }
}

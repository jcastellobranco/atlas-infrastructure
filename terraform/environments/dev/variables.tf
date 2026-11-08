variable "aws_region" { type = string; default = "us-east-1" }
variable "environment" { type = string; default = "dev" }
variable "name" { type = string; default = "atlas" }
variable "vpc_cidr" { type = string; default = "10.42.0.0/16" }
variable "certificate_arn" { type = string }
variable "db_username" { type = string; default = "atlas_admin" }
variable "db_instance_class" { type = string; default = "db.t4g.micro" }
variable "db_multi_az" { type = bool; default = false }
variable "image_uris" {
  type = map(string)
  description = "Six pinned image URIs: api, frontend, worker, agent, rag, evaluation"
  validation {
    condition = length(setsubtract(toset(["api","frontend","worker","agent","rag","evaluation"]),toset(keys(var.image_uris)))) == 0
    error_message = "Supply an image for each of the six services."
  }
}

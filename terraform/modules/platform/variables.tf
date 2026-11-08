variable "name" { type = string }
variable "vpc_cidr" { type = string }
variable "certificate_arn" { type = string }
variable "db_username" { type = string }
variable "db_instance_class" { type = string }
variable "db_multi_az" { type = bool }
variable "image_uris" { type = map(string) }

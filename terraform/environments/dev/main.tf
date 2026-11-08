module "platform" {
  source = "../../modules/platform"
  name = "${var.name}-${var.environment}"
  vpc_cidr = var.vpc_cidr
  certificate_arn = var.certificate_arn
  db_username = var.db_username
  db_instance_class = var.db_instance_class
  db_multi_az = var.db_multi_az
  image_uris = var.image_uris
}

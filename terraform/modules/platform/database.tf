resource "aws_db_subnet_group" "this" {
  name = "${var.name}-db"
  subnet_ids = aws_subnet.private[*].id
}
resource "aws_db_instance" "this" {
  identifier = "${var.name}-postgres"
  engine = "postgres"
  engine_version = "17"
  instance_class = var.db_instance_class
  allocated_storage = 30
  max_allocated_storage = 100
  storage_type = "gp3"
  storage_encrypted = true
  db_name = "platform"
  username = var.db_username
  manage_master_user_password = true
  publicly_accessible = false
  multi_az = var.db_multi_az
  db_subnet_group_name = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]
  backup_retention_period = 7
  deletion_protection = true
  skip_final_snapshot = false
  final_snapshot_identifier = "${var.name}-final-snapshot"
  auto_minor_version_upgrade = true
}


# ALB DNS name
output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

# Endpoint output
output "rds_endpoint" {
  value = aws_db_instance.default.endpoint
}

resource "local_sensitive_file" "db_password" {
  filename = "${path.module}/${var.db_password_file}"
  content = local.db_creds.password
}

resource "local_sensitive_file" "db_username" {
  filename = "${path.module}/${var.db_username_file}"
  content = local.db_creds.username
}

resource "local_sensitive_file" "db_creds" {
  filename = "${path.module}/db_creds.txt"
  content = data.aws_secretsmanager_secret_version.db_creds.secret_string
}
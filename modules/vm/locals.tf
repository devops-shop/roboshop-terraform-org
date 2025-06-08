locals {
  role_name = var.type == "db" ? var.name : "${var.name}-docker"
}


output "aws_region" {
  value = var.region
}

output "cluster_name" {
  value = module.eks.cluster_id
}

output "simple_go_app_namespace" {
  value = var.simple_go_app_namespace
}

output "simple_go_app_service_account_name" {
  value = var.simple_go_app_service_account_name
}

output "dynamodb_table_name" {
  value = var.dynamodb_table_name
}

output "dynamodb_role_arn" {
  value = aws_iam_role.eks_dynamodb_role.arn
}

variable "name" {
  type        = string
  description = "Name of the application. This is used to name infrastructure resources"
}

variable "aws_profile" {
  type        = string
  description = "AWS profile used to deploy infrastructure"
}

variable "region" {
  type        = string
  description = "AWS region to deloy application"
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"
  default     = "192.168.0.0/16"
}

variable "dynamodb_table_name" {
  type        = string
  description = "Name of the dynamodb table used for the simple go app"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes Version 1.21"
  default     = "1.21"
}

variable "kubernetes_admin_role_arn" {
  type        = string
  description = "ARN of AWS IAM role. This role will have admin permissions to the EKS cluster"
}

variable "simple_go_app_service_account_name" {
  type        = string
  description = "Name of the Kubernetes Service Account used in the simple go app"
  default     = "simple-go-app-sa"
}

variable "simple_go_app_namespace" {
  type        = string
  description = "Name of the Kubernetes namespace where the simple go app service account is created"
  default     = "simple-go-app"
}

variable "ssh_public_key_value" {
  type        = string
  description = "A public ssh key. The private key pair will be used to ssh to the worker nodes"
}

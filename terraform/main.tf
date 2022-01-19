#########################################
#          DEFINE PROVIDERS             #
#########################################

provider "aws" {
  region  = var.region
  profile = var.aws_profile

  default_tags {
    tags = {
      WorkspaceName = terraform.workspace
      Terraform     = true
      Stack         = "SimpleGoApp"
    }
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.envoy_cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.envoy_cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.envoy_cluster.token
}

data "aws_eks_cluster" "envoy_cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "envoy_cluster" {
  name = module.eks.cluster_id
}


#########################################
#               CREATE VPC              #
#########################################

locals {
  # We create 4 subnets, 2 private and 2 public
  # Deploy the subnet into different az for HA
  subnets           = cidrsubnets(var.vpc_cidr, 2, 2, 2, 2)
  full_cluster_name = "${var.name}-cluster"

}

data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.11"

  name = var.name
  cidr = var.vpc_cidr

  azs             = slice(data.aws_availability_zones.available.names, 0, 2)
  private_subnets = slice(local.subnets, 0, 2)
  public_subnets  = slice(local.subnets, 2, 4)

  enable_nat_gateway = true

}

#########################################
#             CREATE EKS                #
#########################################

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 17.24"

  cluster_name    = local.full_cluster_name
  cluster_version = var.k8s_version
  subnets         = module.vpc.private_subnets

  vpc_id           = module.vpc.vpc_id
  write_kubeconfig = false
  enable_irsa      = true

  cluster_enabled_log_types = [
    "audit",
    "authenticator",
  ]

  node_groups_defaults = {
    create_launch_template = true
    disk_encrypted         = true
    disk_size              = 20
    disk_type              = "gp3"
    disk_kms_key_id        = data.aws_kms_alias.ebs_service_key.target_key_arn
    ebs_optimized          = true
    key_name               = aws_key_pair.worker_node_key_pair.key_name
  }

  node_groups = [
    {
      ami_type         = "AL2_x86_64"
      name_prefix      = "intel-m5-"
      instance_types   = ["m5.xlarge"]
      desired_capacity = 2
      min_capacity     = 2
      max_capacity     = 3
      additional_tags = {
        Name = "${local.full_cluster_name}-intel-m5"
      }
    }
  ]

  map_roles = [
    {
      rolearn  = var.kubernetes_admin_role_arn
      username = "KubernetesAdmin"
      groups = [
        "system:masters"
      ]
    }
  ]
}

resource "aws_key_pair" "worker_node_key_pair" {
  key_name   = "${local.full_cluster_name}/KEY"
  public_key = var.ssh_public_key_value
}

data "aws_caller_identity" "current" {}

data "aws_kms_alias" "ebs_service_key" {
  name = "alias/aws/ebs"
}

#########################################
#        CREATE DYNAMODB                #
#########################################

resource "aws_dynamodb_table" "simple_go_app_db_table" {
  name           = var.dynamodb_table_name
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "Title"
  range_key      = "Year"

  attribute {
    name = "Title"
    type = "S"
  }

  attribute {
    name = "Year"
    type = "N"
  }
}


resource "aws_iam_role" "eks_dynamodb_role" {
  name_prefix = "${var.name}-access-dynamodb-"
  assume_role_policy = data.aws_iam_policy_document.eks_dynamodb_assume_policy.json

  inline_policy {
    name = "access-dynamodb"
    policy = jsonencode(
      {
        "Version" : "2012-10-17",
        "Statement" : [
          {
            "Effect" : "Allow",
            "Action" : [
              "dynamodb:GetItem",
              "dynamodb:PutItem"
            ],
            "Resource" : [
              aws_dynamodb_table.simple_go_app_db_table.arn
            ]
          }
        ]
      }
    )
  }
}

data "aws_iam_policy_document" "eks_dynamodb_assume_policy" {
  statement {
    effect = "Allow"
    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${trimprefix(module.eks. cluster_oidc_issuer_url, "https://")}:sub"
      values = [
        "system:serviceaccount:${var.simple_go_app_namespace}:${var.simple_go_app_service_account_name}"
      ]
    }
  }
}
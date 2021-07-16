provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "~/.aws/credentials"
}

locals {
  cluster_name = "fullstack-web-template-frontend"
}

module "network" {
  source = "./modules/network"

  tags = {
    // Necessary for AWS Load Balancer Controller
    // https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
  }

  public_subnet_tags = {
    // Necessary for AWS Load Balancer Controller
    // https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                      = "1"
  }
  private_subnet_tags = {
    // Necessary for AWS Load Balancer Controller
    // https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html
    "kubernetes.io/cluster/${local.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"             = "1"
  }
}

module "cluster" {
  source       = "./modules/cluster"
  cluster_name = local.cluster_name
  vpc_id       = module.network.vpc_id
  subnets      = module.network.private_subnets
}

module "load_balancer_controller" {
  source     = "./modules/aws_load_balancer_controller"
  cluster    = module.cluster.cluster
  kubeconfig = module.cluster.kubeconfig
}

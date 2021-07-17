provider "aws" {
  region                  = "us-east-2"
  shared_credentials_file = "~/.aws/credentials"
}

provider "helm" {
  kubernetes {
    host                   = module.cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(module.cluster.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster.name]
      command     = "aws"
    }
  }
}

provider "kubernetes" {
  host                   = module.cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(module.cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", module.cluster.cluster.name]
    command     = "aws"
  }
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

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.cluster.name]
    command     = "aws"
  }
}

data "tls_certificate" "cluster" {
  url = data.aws_eks_cluster.cluster.identity.0.oidc.0.issuer
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.20"
  subnets         = var.subnets
  vpc_id          = var.vpc_id

  // openid provider
  enable_irsa                 = true
  eks_oidc_root_ca_thumbprint = data.tls_certificate.cluster.certificates.0.sha1_fingerprint

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                          = "worker-group-1"
      instance_type                 = "t2.small"
      asg_desired_capacity          = 1
      additional_security_group_ids = [aws_security_group.worker_group_mgmt_one.id]
    },
    # {
    #   name                          = "worker-group-2"
    #   instance_type                 = "t2.small"
    #   additional_security_group_ids = [aws_security_group.worker_group_mgmt_two.id]
    #   asg_desired_capacity          = 1
    # },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

resource "aws_security_group" "worker_group_mgmt_one" {
  name_prefix = "worker_group_mgmt_one"
  vpc_id      = var.vpc_id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

# resource "aws_security_group" "worker_group_mgmt_two" {
#   name_prefix = "worker_group_mgmt_two"
#   vpc_id      = module.vpc.vpc_id

#   ingress {
#     from_port = 22
#     to_port   = 22
#     protocol  = "tcp"

#     cidr_blocks = [
#       "192.168.0.0/16",
#     ]
#   }
# }

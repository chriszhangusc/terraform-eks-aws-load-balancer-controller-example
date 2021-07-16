provider "helm" {
  kubernetes {
    host                   = var.cluster.endpoint
    cluster_ca_certificate = base64decode(var.cluster.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = ["eks", "get-token", "--cluster-name", var.cluster.name]
      command     = "aws"
    }
  }
}

resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  depends_on = [null_resource.apply_crds]

  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  atomic     = true

  set {
    name  = "clusterName"
    value = var.cluster.name
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }
}


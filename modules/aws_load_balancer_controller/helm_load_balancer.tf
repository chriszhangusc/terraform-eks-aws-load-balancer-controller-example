
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


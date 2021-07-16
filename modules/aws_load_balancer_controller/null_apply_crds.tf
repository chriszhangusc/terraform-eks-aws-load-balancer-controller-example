resource "null_resource" "apply_crds" {
  depends_on = [aws_iam_policy.aws_load_balancer_controller_policy]
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    on_failure  = fail
    interpreter = ["/bin/bash", "-c"]
    environment = {
      KUBECONFIG = base64encode(var.kubeconfig)
    }
    when    = create
    command = <<EOT
      kubectl --kubeconfig <(echo $KUBECONFIG | base64 --decode) apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller/crds?ref=master"
    EOT
  }
}

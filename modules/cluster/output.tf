output "cluster" {
  value = data.aws_eks_cluster.cluster
}

output "kubeconfig" {
  value = module.eks.kubeconfig
}

# Terraform EKS AWS Load Balancer Controller Example

This is an example that shows how to create an [Amazon EKS](https://aws.amazon.com/eks/?whats-new-cards.sort-by=item.additionalFields.postDateTime&whats-new-cards.sort-order=desc&eks-blogs.sort-by=item.additionalFields.createdDate&eks-blogs.sort-order=desc) cluster with [AWS Load Balancer Controller](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html) in [Terraform](https://github.com/hashicorp/terraform)

## Installation

1. `terraform init`
2. `terraform plan`
3. `terraform apply`
4. Update your kubernetes config (by default stored in ~/.kube/config) to point to the new cluster using the console output from the last step.

## Deploy game 2048 to the new cluster

1. Run `kubectl apply -f ./game-2048.yaml`
2. Check if the ingress is successfully created `k get ingress ingress-2048 -n game-2048`, there should be an address assigned

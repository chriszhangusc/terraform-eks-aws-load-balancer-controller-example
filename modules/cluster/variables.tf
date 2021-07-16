variable "vpc_id" {

}

variable "subnets" {
  type    = list(string)
  default = []
}

variable "cluster_name" {
  type    = string
  default = "default-cluster"
}

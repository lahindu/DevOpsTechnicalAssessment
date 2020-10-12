variable "vpc_cidr" {
  description = "CIDR for the VPC"
  default     = "172.30.0.0/16"
}

variable "eks_cluster_name" {
  description = "EKS cluster Name"
  default     = "eks_1"
}

variable "public_subnet_cidr_blocks" {
  description = "Public Subnet CIDR list"
  default     = [ "172.30.0.0/24", "172.30.1.0/24", "172.30.2.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "Private Subnet CIDR list"
  default     = [ "172.30.100.0/24", "172.30.101.0/24", "172.30.102.0/24"]
}

variable "environment" {
    description = "environment name"
    default     = "EnvironmentName"
}

variable "project" {
    description = "project name"
    default = "ProjectName"
}
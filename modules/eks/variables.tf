variable "eks_cluster_role" {
  description = "EKS cluster role"
  default     = "eksClusterRole"
}

variable "eks_cluster_name" {
  description = "EKS cluster Name"
  default     = "DEV-EKS-1"
}

variable "environment" {
    description = "environment name"
    default     = "EnvironmentName"
}

#variable "public_subnet_count" {
#    description = "Public subnet count"
#    default     = "public_subnet_count"
#}

variable "subnet_id_in_vpc" {
  description = "Public Subnet ID list"
  default     = ["subnet-xxx", "subnet-xxx"]
}

variable "public_subnet_ids" {
  description = "Public Subnet ID list"
  default     = ["subnet-xxx", "subnet-xxx"]
}

variable "private_subnet_ids" {
  description = "Private Subnet ID list"
  default     = "subnet-xxx"
}

variable "role_eks_node_group" {
  description = "EKS node group role"
  default     = "EKSNodeGroupRole"
}

variable "vpc_id" {
  description = "EKS node group role"
  default     = "vpc-xxx"
}

variable "cluster_sg_name" {
  description = "EKS Cluster Security group name"
  default     = "SG-Name"
}

variable "nodes_sg_name" {
  description = "EKS Cluster node group Security group name"
  default     = "NG-SG-Name"
}

variable "ami_type" {
  description = "EKS optimized image ID"
  default     = "ami-xxx"
}

variable "disk_size" {
  description = "EKS disk size"
  default     = "20"
}

variable "instance_types" {
  description = "EKS Cluster node group Security group name"
  default     = ["t3.micro"]
}

variable "asg_public_desired_size" {
  description = "EKS ASG desired size"
  default     = "1"
}

variable "asg_public_max_size" {
  description = "ASG max size"
  default     = "1"
}

variable "asg_public_min_size" {
  description = "EKS ASG min size"
  default     = "1"
}

variable "asg_private_desired_size" {
  description = "EKS ASG desired size"
  default     = "1"
}

variable "asg_private_max_size" {
  description = "ASG max size"
  default     = "1"
}

variable "asg_private_min_size" {
  description = "EKS ASG min size"
  default     = "1"
}
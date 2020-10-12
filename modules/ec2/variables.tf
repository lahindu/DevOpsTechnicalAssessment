variable "environment" {
  description = "Environment name"
  default     = "environment"
}

variable "instance_name" {
  description = "instance name"
  default     = "instance_name"
}

variable "instance_public_key" {
  description = "instance SSH Public Key name"
  default     = "ssh-rsa AAAA**************"
}

variable "instance_ami" {
  description = "Ubuntu 18.0"
  default     = "ami-0123b531fc646552f"
}

variable "instance_type" {
  description = "Instance type of Server"
  default     = "t2.micro"
}

variable "private_ip" {
  default = "10.170.0.1"
}

variable "vpc_id" {
  description = "VPC ID"
  default = "vpc-xxxxxx"
}

variable "subnet_id" {
  description = "Subnet IDs"
  default = "subnet-xxxx"
}

variable "ec2_eks_cluster_role" {
  description = "EC2 to EKS cluster role"
  default = "EC2-2-EKS-ROLE"
}

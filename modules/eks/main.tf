resource "aws_iam_role" "role_eks" {
    name                  = var.eks_cluster_role
    assume_role_policy    = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
    policy_arn            = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role                  = aws_iam_role.role_eks.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
    policy_arn            = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role                  = aws_iam_role.role_eks.name
}

resource "aws_iam_role_policy_attachment" "AWSElasticLoadBalancingServiceRolePolicy" {
    policy_arn            = "arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess"
    role                  = aws_iam_role.role_eks.name
}

resource "aws_eks_cluster" "eks" {
    name                   = var.eks_cluster_name
    role_arn               = aws_iam_role.role_eks.arn
    vpc_config {
      subnet_ids           = var.subnet_id_in_vpc
    }
    tags                   = {
        Name               = var.eks_cluster_name
    }
}

# EKS Worker Node Group Security Group
resource "aws_security_group" "eks_cluster" {
  name                    = "${var.eks_cluster_name}-${var.cluster_sg_name}"
  description             = "Cluster communication with worker nodes"
  vpc_id                  = var.vpc_id
  tags                    = {
    Name                  = var.cluster_sg_name
  }
}
resource "aws_security_group_rule" "cluster_inbound" {
  description              = "Allow worker nodes to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 443
  type                     = "ingress"
}
resource "aws_security_group_rule" "cluster_outbound" {
  description              = "Allow cluster API Server to communicate with the worker nodes"
  from_port                = 1024
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "egress"
}
resource "aws_security_group_rule" "cluster_inbound_public" {
  description              = "Allow cluster API Server to communicate public"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_cluster.id
  cidr_blocks              = ["0.0.0.0/0"]
  to_port                  = 65535
  type                     = "ingress"
}

# EKS Worker Node Group Security Group
resource "aws_security_group" "eks_nodes" {
  name                    = var.nodes_sg_name
  description             = "Security group for all nodes in the cluster"
  vpc_id                  = var.vpc_id
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  tags                    = {
    Name                                            = var.nodes_sg_name
    "kubernetes.io/cluster/${var.eks_cluster_name}" = "owned"
  }
}
resource "aws_security_group_rule" "nodes" {
  description              = "Allow nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_nodes.id
  to_port                  = 65535
  type                     = "ingress"
}
resource "aws_security_group_rule" "nodes_inbound" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.eks_nodes.id
  source_security_group_id = aws_security_group.eks_cluster.id
  to_port                  = 65535
  type                     = "ingress"
}

# Worker Node Group IAM Role
resource "aws_iam_role" "eks_nodes" {
  name                    = "${var.eks_cluster_name}-${var.environment}-NG-ROLE"
  assume_role_policy      = data.aws_iam_policy_document.assume_workers.json
}

data "aws_iam_policy_document" "assume_workers" {
  statement {
    effect                = "Allow"
    actions               = ["sts:AssumeRole"]
    principals {
      type                = "Service"
      identifiers         = ["ec2.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy_attachment" "aws_eks_worker_node_policy" {
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role                    = aws_iam_role.eks_nodes.name
}
resource "aws_iam_role_policy_attachment" "aws_eks_cni_policy" {
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role                    = aws_iam_role.eks_nodes.name
}
resource "aws_iam_role_policy_attachment" "ec2_read_only" {
  policy_arn              = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role                    = aws_iam_role.eks_nodes.name
}
resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {
  policy_arn              = aws_iam_policy.cluster_autoscaler_policy.arn
  role                    = aws_iam_role.eks_nodes.name
}
resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name                    = "ClusterAutoScaler"
  description             = "Give the worker node running the Cluster Autoscaler access to required resources and actions"
policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:DescribeLaunchConfigurations",
                "autoscaling:DescribeTags",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

#Worker Node Groups for Public Subnets
# Nodes in public subnet
resource "aws_eks_node_group" "public" {
  cluster_name        = aws_eks_cluster.eks.name
  node_group_name     = "${var.eks_cluster_name}-NG-PUBLIC"
  node_role_arn       = aws_iam_role.eks_nodes.arn
  subnet_ids          = var.public_subnet_ids
  ami_type            = var.ami_type
  disk_size           = var.disk_size
  instance_types      = var.instance_types
  scaling_config {
    desired_size      = var.asg_public_desired_size
    max_size          = var.asg_public_max_size
    min_size          = var.asg_public_min_size
  }
  tags = {
    Name              = "${var.eks_cluster_name}-NG-PUBLIC"
  }
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
  ]
}

#Worker Node Groups for Private Subnets
# Nodes in private subnets
resource "aws_eks_node_group" "private" {
  cluster_name        = aws_eks_cluster.eks.name
  node_group_name     = "${var.eks_cluster_name}-NG-PRIVATE"
  node_role_arn       = aws_iam_role.eks_nodes.arn
  subnet_ids          = var.private_subnet_ids
  ami_type            = var.ami_type
  disk_size           = var.disk_size
  instance_types      = var.instance_types
  scaling_config {
    desired_size      = var.asg_private_desired_size
    max_size          = var.asg_private_max_size
    min_size          = var.asg_private_min_size
  }
  tags = {
    Name              = "${var.eks_cluster_name}-NG-PRIVATE"
  }
# Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.aws_eks_worker_node_policy,
    aws_iam_role_policy_attachment.aws_eks_cni_policy,
    aws_iam_role_policy_attachment.ec2_read_only,
  ]
}
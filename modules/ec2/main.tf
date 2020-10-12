resource "aws_eip" "eip" {
  instance                = aws_instance.ec2.id
  vpc                     = true
  tags                    = {
    Name                  = "${var.instance_name}-EIP"
  }
}

# Define SSH key pair for instances
resource "aws_key_pair" "key" {
  key_name                = var.instance_name
  public_key              = var.instance_public_key
}

# Define the security group for FT instance
resource "aws_security_group" "ec2-sg" {
  name                    = "${var.instance_name}-SG"
  description             = "${var.instance_name} instance security group"
  vpc_id                  = var.vpc_id
  egress {
    from_port             = 0
    to_port               = 0
    protocol              = "-1"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  ingress {
    from_port             = 22
    to_port               = 22
    protocol              = "tcp"
    cidr_blocks           = ["0.0.0.0/0"]
  }
  tags                    = {
    Name                  = "${var.instance_name}-SG"
    Environment           = var.environment
  }
}

resource "aws_iam_role" "role_ec2" {
    name                  = var.ec2_eks_cluster_role
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
    policy_arn            = "arn:aws:iam::aws:policy/AdministratorAccess"
    role                  = aws_iam_role.role_ec2.name
}

resource "aws_iam_instance_profile" "ec2_iam_profile" {
  name  = "EC2-IAM-PROFILE"
  role = aws_iam_role.role_ec2.name
}

resource "aws_instance" "ec2" {
  ami                         = var.instance_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.key.key_name
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  private_ip                  = var.private_ip
  associate_public_ip_address = true
  source_dest_check           = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_iam_profile.name
  root_block_device {
      delete_on_termination   = false
      volume_size             = 20
      volume_type             = "gp2"
  }
  tags                        = {
    Name                      = var.instance_name
    Environment               = var.environment
  }

  #provisioner "file" {
  #  source                    = "scripts.sh"
  #  destination               = "/tmp/scripts.sh"
  #}

  provisioner "remote-exec" {
    inline = [
      "echo \"The server's IP address is ${self.private_ip}\"",
      "chmod +x /tmp/scripts.sh",
      "/tmp/scripts.sh"
    ]
  }
  
  #  connection {
  #    type        = "ssh"
  #    user        = "ec2-user"
  #    password    = ""
  #    private_key = file(var.keyPath)
  #    host        = self.public_ip
  #}

}


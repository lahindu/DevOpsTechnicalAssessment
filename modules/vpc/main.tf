# Define VPC
resource "aws_vpc" "vpc" {
    cidr_block           = var.vpc_cidr
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name                                            = "${var.project}-${var.environment}"
        Environment                                     = var.environment
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
}

# Get the availability zones list
data "aws_availability_zones" "available" {
}

# Define the public subnets
resource "aws_subnet" "public_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    count                   = length(var.private_subnet_cidr_blocks)
    cidr_block              = var.public_subnet_cidr_blocks[count.index]
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    map_public_ip_on_launch = true
    tags                    = {
        "kubernetes.io/role/elb"                        = 1
        Name                                            = "${var.project}-${var.environment}-PUBLIC-${var.public_subnet_cidr_blocks[count.index]}"
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
        
    }
}

# Define the private subnet
resource "aws_subnet" "private_subnet" {
    vpc_id                  = aws_vpc.vpc.id
    count                   = length(var.private_subnet_cidr_blocks)
    cidr_block              = var.private_subnet_cidr_blocks[count.index]
    availability_zone       = data.aws_availability_zones.available.names[count.index]
    tags                    = {
        "kubernetes.io/role/internal-elb"               = 1
        Name                                            = "${var.project}-${var.environment}-PRIVATE-${var.private_subnet_cidr_blocks[count.index]}"
        "kubernetes.io/cluster/${var.eks_cluster_name}" = "shared"
    }
}

# Define the internet gateway
resource "aws_internet_gateway" "igw" {
    vpc_id                  = aws_vpc.vpc.id
    tags                    = {
        Name                = "${var.project}-${var.environment}-IGW"
        Environment         = var.environment
    }
}

# Define the public route table
resource "aws_route_table" "vpc_public_rt" {
    vpc_id                  = aws_vpc.vpc.id
    tags                    = {
        Name                = "${var.project}-${var.environment}-PUBLIC-RT"
        Environment         = var.environment
    }
}

# Assign the IGW to public route table
resource "aws_route" "public_rt_internet_gw" {
    route_table_id          = aws_route_table.vpc_public_rt.id
    destination_cidr_block  = "0.0.0.0/0"
    gateway_id              = aws_internet_gateway.igw.id
}

# Assign the route table to the public Subnets
resource "aws_route_table_association" "web_public_rt" {
    count                   = length(var.public_subnet_cidr_blocks)
    subnet_id               = aws_subnet.public_subnet[count.index].id
    route_table_id          = aws_route_table.vpc_public_rt.id
}

# Define Elastic IP for NAT Gateway
resource "aws_eip" "nat_gw_eip" {
    vpc                     = true
}

# Define NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
    allocation_id           = aws_eip.nat_gw_eip.id
    subnet_id               = aws_subnet.public_subnet[0].id
    tags                    = {
        Name                = "${var.project}-${var.environment}-NAT"
        Environment         = var.environment
    }
}

# Define the private route table
resource "aws_route_table" "vpc_private_rt" {
    vpc_id                  = aws_vpc.vpc.id
    tags                    = {
        Name                = "${var.project}-${var.environment}-PRIVATE-RT"
        Environment         = var.environment
    }
}

# Assign the NAT gateway to private route table
resource "aws_route" "private_rt_nat_gw" {
    route_table_id          = aws_route_table.vpc_private_rt.id
    destination_cidr_block  = "0.0.0.0/0"
    nat_gateway_id          = aws_nat_gateway.nat_gw.id
}

# Assign the route table to the private Subnets
resource "aws_route_table_association" "web_private_rt_a" {
    count                   = length(var.private_subnet_cidr_blocks)
    subnet_id               = aws_subnet.private_subnet[count.index].id
    route_table_id          = aws_route_table.vpc_private_rt.id
}
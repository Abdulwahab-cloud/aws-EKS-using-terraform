resource "aws_vpc" "eks-vpc" {
    cidr_block = "10.0.0.0/16"

    enable_dns_hostnames = true
    enable_dns_support = true
tags = {
  Name = "EKS-VPC-${local.env}"
}
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    Name = "${local.env}-igw"
  }
}

resource "aws_subnet" "private1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.0.0/19"
    availability_zone = local.zone1
  tags = {
    "Name" = "private-${local.zone1}"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "private2" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.32.0/19"
    availability_zone = local.zone2
  tags = {
    "Name" = "private-${local.zone2}"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public1" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.64.0/19"
    availability_zone = local.zone1
    map_public_ip_on_launch = true
  tags = {
    "Name" = "public-${local.zone1}"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${local.eks_name}" = "owned"
  }
}

resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.eks-vpc.id
    cidr_block = "10.0.96.0/19"
    availability_zone = local.zone2
    map_public_ip_on_launch = true
  tags = {
    "Name" = "public-${local.zone2}"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/${local.eks_name}" = "owned"
  }
}

resource "aws_eip" "eip-nat" {
    domain = "vpc"
    tags = {
      Name = "${local.env}-eip-nat"
    }
  
}

resource "aws_nat_gateway" "nat" {
   allocation_id = aws_eip.eip-nat.id
   subnet_id = aws_subnet.public1.id

   tags = {
     Name = "${local.env}-nat"
   }
  depends_on = [ aws_internet_gateway.igw ]
}


resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc.eks-vpc.id

    route  {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
      Name = "${local.env}-private-rt"
    }
  
}

resource "aws_route_table" "public_route" {
vpc_id = aws_vpc.eks-vpc.id

route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
}
  tags = {
    Name = "${local.env}-public-rt"
  }
}

resource "aws_route_table_association" "pr-att1" {
  subnet_id = aws_subnet.private1.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "pr-att2" {
  subnet_id = aws_subnet.private2.id
  route_table_id = aws_route_table.private_route.id
}

resource "aws_route_table_association" "pc-att1" {
  subnet_id = aws_subnet.public1.id
  route_table_id = aws_route_table.public_route.id
}

resource "aws_route_table_association" "pc-att2" {
  subnet_id = aws_subnet.public2.id
  route_table_id = aws_route_table.public_route.id
}
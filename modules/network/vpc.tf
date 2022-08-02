resource "aws_vpc" "eks-vpc" {
  cidr_block = var.vpc-cidr-block
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy = "default"
  tags = {
    Name = var.vpc-name
  }
}


################## Public Subnet ###################

resource "aws_subnet" "public-subnet" {
  count = length(var.public-cidr)
  vpc_id = aws_vpc.eks-vpc.id
  cidr_block = var.public-cidr[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.public-subnet-name}-${count.index}"
  }
}


################## Private Subnet ###################

resource "aws_subnet" "private-subnet" {
  count = length(var.private-cidr)
  vpc_id = aws_vpc.eks-vpc.id
  cidr_block = var.private-cidr[count.index]
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.private-subnet-name}-${count.index+1}"
  }
}

################## Internet Gateway ###################


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.eks-vpc.id
  tags = {
    "Name" = "${var.igw-name}"
  }
}


################## NAT Gateway ###################

resource "aws_eip" "nat-aws-eip" {
  vpc = true
  depends_on =  [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat" {
  #count = length(var.public-cidr)
  allocation_id = aws_eip.nat-aws-eip.id
  subnet_id = aws_subnet.public-subnet[1].id
  tags = {
    "Name" = "${var.nat-name}"
  }
}

################## Route Table  ###################

resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.eks-vpc.id
  #count = length(var.public-cidr)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  #destination_cidr_block = "0.0.0.0/0"
  tags = {
    "Name" = "${var.pub-rt-name}"
  }
}


resource "aws_route_table" "pvt-rt" {
  vpc_id = "${aws_vpc.eks-vpc.id}"  
  #count = length(var.private-cidr)

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
  tags = {
    "Name" = "${var.pvt-rt-name}"
  }
}


################## Route Table Association ###################


resource "aws_route_table_association" "pub-rta" {
  count = "${length(var.public-cidr)}"
  subnet_id = "${element(aws_subnet.public-subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.pub-rt.id}"
}

resource "aws_route_table_association" "pvt-rta" {
  count = length(var.private-cidr)
  subnet_id = aws_subnet.private-subnet[count.index].id
  route_table_id = element(aws_route_table.pvt-rt.*.id,count.index)
}

#1.Create a custom VPC (Name: Development) and 2 Public subnets and 1 Private subnet in different AZs in the North Virginia region.

#vpc creation
resource "aws_vpc" "Development" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
 enable_dns_support   = true
  enable_dns_hostnames = true  # Enable DNS hostnames
  tags = {
    Name = "Development"
  }
}

#subnet creation

resource "aws_subnet" "pub_sub1" {
  vpc_id     = aws_vpc.Development.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "pub_sub1"
  }
}
resource "aws_subnet" "pub_sub2" {
  vpc_id     = aws_vpc.Development.id
  cidr_block = "10.0.2.0/24"
   availability_zone = "us-east-1b"

  tags = {
    Name = "pub_sub2"
  }
}

resource "aws_subnet" "pvt_sub1" {
  vpc_id     = aws_vpc.Development.id
  cidr_block = "10.0.3.0/24"
   availability_zone = "us-east-1c"

  tags = {
    Name = "pvt_sub1"
  }
}

#internet gateway

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.Development.id

  tags = {
    Name = "internetgate"
  }
}

# Create an Elastic IP for the NAT Gateway
resource "aws_eip" "neweip" {
  tags = {
    Name = "Example EIP"
  }
}
#nat gateway creation
resource "aws_nat_gateway" "gw_NAT" {
  allocation_id = aws_eip.neweip.id
  subnet_id     = aws_subnet.pub_sub1.id

  tags = {
    Name = "gw_NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC first it will create internet gateway then it create nat gateway.
  depends_on = [aws_internet_gateway.gw]
}

#define route table

resource "aws_route_table" "pub_route" {
  vpc_id = aws_vpc.Development.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  } 
}

resource "aws_route_table" "pvt_route" {
  vpc_id = aws_vpc.Development.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw_NAT.id
  } 
 
  # vpc peering route  
 route { 
  cidr_block = "172.16.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_prod.id 
}
}

#route table association

resource "aws_route_table_association" "assoc_pub1" {
  subnet_id      = aws_subnet.pub_sub1.id
  route_table_id = aws_route_table.pub_route.id
}
resource "aws_route_table_association" "assoc_pub2" {
  subnet_id      = aws_subnet.pub_sub2.id
  route_table_id = aws_route_table.pub_route.id
}
resource "aws_route_table_association" "assoc_pvt" {
  subnet_id      = aws_subnet.pvt_sub1.id
  route_table_id = aws_route_table.pvt_route.id
}

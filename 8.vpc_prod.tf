#VPC production
#5.	Create a custom VPC (Name: Production) and 2 Public subnets and 1 Private subnet in different AZs in the North Virginia region.

resource "aws_vpc" "Production" {

cidr_block = "172.16.0.0/16"
instance_tenancy = "default"
 enable_dns_support   = true
  enable_dns_hostnames = true  # Enable DNS hostnames
tags = {
Name = "Production"
}
}

resource "aws_subnet" "pub_prodsub1" {
vpc_id = aws_vpc.Production.id
cidr_block = "172.16.1.0/24"
availability_zone = "us-east-1a"
tags = {
Name = "pub_sub1"
}
}

resource "aws_subnet" "pub_prodsub2" {
vpc_id = aws_vpc.Production.id
cidr_block = "172.16.2.0/24"
availability_zone = "us-east-1b"
tags = {
Name = "pub_sub2"
}
}

resource "aws_subnet" "pvt_dbsub1" {
vpc_id = aws_vpc.Production.id
cidr_block = "172.16.3.0/24"
availability_zone = "us-east-1c"
tags = {
Name = "pvt_sub1"
}
}

resource "aws_subnet" "pvt_dbsub2" {
vpc_id = aws_vpc.Production.id
cidr_block = "172.16.4.0/24"
availability_zone = "us-east-1d"
tags = {
name = "pvt_sub2"
}
}
#internet gateway

resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.Production.id

  tags = {
    Name = "Prod_internetgate"
  }
}

#define route table

resource "aws_route_table" "prod_pub_route" {
  vpc_id = aws_vpc.Production.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  } 
}


resource "aws_route_table" "prod_pvt_route" {
  vpc_id = aws_vpc.Production.id

  route {
    cidr_block = "10.0.0.0/16"
vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_prod.id  # Ensure this connection exists
  } 
}
# associate route table

resource "aws_route_table_association" "prod_assoc_pub1" {
  subnet_id      = aws_subnet.pub_prodsub1.id
  route_table_id = aws_route_table.prod_pub_route.id
}
resource "aws_route_table_association" "assoc_prod_pub2" {
  subnet_id      = aws_subnet.pub_prodsub2.id
  route_table_id = aws_route_table.prod_pub_route.id
}

resource "aws_route_table_association" "assoc_prodpvt1" {
  subnet_id      = aws_subnet.pvt_dbsub1.id
  route_table_id = aws_route_table.prod_pvt_route.id
}

resource "aws_route_table_association" "assoc_prodpvt2" {
  subnet_id      = aws_subnet.pvt_dbsub2.id
  route_table_id = aws_route_table.prod_pvt_route.id
}


#create database and security
#6.Create a MySQL engine based RDS database with the initial database name as PRT in the Production VPC.

resource "aws_security_group" "prod_sec" {
name = "prod_security_grp"
description = "prod_security_grp"
vpc_id = aws_vpc.Production.id
}

resource "aws_security_group_rule" "allow_db_access" {
  type              = "ingress"
  from_port         = 3306  # MySQL port
  to_port           = 3306
  protocol          = "tcp"
  security_group_id = aws_security_group.prod_sec.id  # Security group for RDS
  cidr_blocks       = ["10.0.3.0/24"]  # Replace with the CIDR block of the Development VPC
}


resource "aws_security_group_rule" "allow_dbssh_access" {
  type              = "ingress"
  from_port         = 22  # ssh  port
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.prod_sec.id  # Security group for RDS
  cidr_blocks       = ["10.0.3.0/24"]  # Replace with the CIDR block of the Development VPC
}

# db subnet group
resource "aws_db_subnet_group" "my_db_subnet_group" {
  name       = "my-db-subnet-group"
  subnet_ids = [aws_subnet.pvt_dbsub1.id,aws_subnet.pvt_dbsub2.id]

  tags = {
    Name = "MyDBSubnetGroup"
  }
}
resource "aws_db_instance" "my_sqldb" { 
  identifier           = "my-production-db" 
  allocated_storage    = 10
  db_name              = "PRT"
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  username             = "admin"
  password             = "admin1234"
  parameter_group_name = "default.mysql8.0" #for mysql
  skip_final_snapshot  = true
  multi_az             = false # for single az
  db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.name
  # Attach the security group for RDS
  vpc_security_group_ids = [aws_security_group.prod_sec.id]

  depends_on     = [aws_subnet.pvt_dbsub1, aws_subnet.pvt_dbsub2, aws_security_group.prod_sec]
}

#Define prod DB nacl

resource "aws_network_acl" "pvt_dbsubnet_nacl" {

  vpc_id = aws_vpc.Production.id
    tags = {
    Name        = "database-subnet-nacl"
  }
}

# Inbound Rules

# Allow MySQL/Aurora (3306) from application subnet
resource "aws_network_acl_rule" "allow_mysql_inbound" {
  network_acl_id = aws_network_acl.pvt_dbsubnet_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "10.0.3.0/24"  # Application subnet CIDR
  from_port      = 3306
  to_port        = 3306
}


# Inbound rule for ssh
resource "aws_network_acl_rule" "allow_dbssh_inbound" {
  network_acl_id = aws_network_acl.pvt_dbsubnet_nacl.id
  rule_number    = 110
  protocol       = "tcp"        # All traffic
  rule_action    = "allow"
  egress         = false
  cidr_block     = "10.0.3.0/24"  # e.g., "10.0.0.0/16"
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "allow_db_ephermal_inbound" {
  network_acl_id = aws_network_acl.pvt_dbsubnet_nacl.id
  rule_number    = 120
  protocol       = "tcp"        # All traffic
  rule_action    = "allow"
  egress         = false
  cidr_block     = "10.0.3.0/24"  # e.g., "10.0.0.0/16"
  from_port      = 1024
  to_port        = 65535
}


# Outbound Rules

resource "aws_network_acl_rule" "allow_mysql_outbound" {
  network_acl_id = aws_network_acl.pvt_dbsubnet_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "10.0.3.0/24"  # Application subnet CIDR
  from_port      = 3306
  to_port        = 3306
}

# oubound ssh
resource "aws_network_acl_rule" "allow_dbssh_outbound" {
  network_acl_id = aws_network_acl.pvt_dbsubnet_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "10.0.3.0/24"  # Application subnet CIDR
  from_port      = 22
  to_port        = 22
}

# Allow responses to pvt subnet
resource "aws_network_acl_rule" "allow_ephermal_outbound" {
  network_acl_id = aws_network_acl.pvt_dbsubnet_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "10.0.3.0/24" # Application subnet CIDR
  from_port      = 1024
  to_port        = 65535
}
# NACL Association with Database Subnet

resource "aws_network_acl_association" "pvt_nacl_association1" {
  network_acl_id = aws_network_acl.pvt_dbsubnet_nacl.id
  subnet_id      = aws_subnet.pvt_dbsub1.id  # Replace with your subnet resource
}
resource "aws_network_acl_association" "pvt_nacl_association2" {
  network_acl_id = aws_network_acl.pvt_dbsubnet_nacl.id
  subnet_id      = aws_subnet.pvt_dbsub2.id  # Replace with your subnet resource
}

# MySQL/Aurora: 3306 - PostgreSQL: 5432- SQL Server: 1433 - Oracle: 1521 - MongoDB: 27017 

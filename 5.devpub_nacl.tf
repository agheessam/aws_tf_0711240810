

# Create VPC NACL

resource "aws_network_acl" "pub_subnet_nacl" {
  vpc_id = aws_vpc.Development.id
  
    tags = {
    Name = "main-nacl"
  }
}
  
# Inbound Rules
resource "aws_network_acl_rule" "allow_http_inbound" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  rule_number    = 100
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}
resource "aws_network_acl_rule" "allow_http_outbound" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  rule_number    = 101
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
}

# https

resource "aws_network_acl_rule" "allow_https_inbound" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  rule_number    = 110
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "allow_https_outbound" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  rule_number    = 111
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}
# ssh
resource "aws_network_acl_rule" "allow_ssh_inbound" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  rule_number    = 120
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"  # Replace with your IP range
  from_port      = 22
  to_port        = 22
}

resource "aws_network_acl_rule" "allow_ssh_outbound" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  rule_number    = 121
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
  from_port      = 22
  to_port        = 22
}
#ephermal
resource "aws_network_acl_rule" "allow_ephermal_inbound" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  rule_number    = 130
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "allow_ephemeral_outbound_devpub" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  rule_number    = 131
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

# NACL Association with Subnet

resource "aws_network_acl_association" "pub_nacl_association1" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  subnet_id      = aws_subnet.pub_sub1.id  # Replace with your subnet resource
}
resource "aws_network_acl_association" "pub_nacl_association2" {
  network_acl_id = aws_network_acl.pub_subnet_nacl.id
  subnet_id      = aws_subnet.pub_sub2.id  # Replace with your subnet resource
}

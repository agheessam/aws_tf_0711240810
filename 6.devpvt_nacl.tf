
  # Create NACL for private subnet

resource "aws_network_acl" "pvt_subnet_nacl" {
  vpc_id = aws_vpc.Development.id

tags = { 
          name = "pvt_sub_nacl"
}
}  

# Allow inbound traffic from http
resource "aws_network_acl_rule" "allow_http_inbound_pvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 100
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"  
  from_port      = 80
  to_port        = 80
}
# Allow outbound traffic to http
resource "aws_network_acl_rule" "allow_http_outbound_pvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 101
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"  
  from_port      = 80
  to_port        = 80
}

# Allow inbound traffic from https
resource "aws_network_acl_rule" "allow_https_inbound_pvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 110
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"  
  from_port      = 443
  to_port        = 443
}
# Allow outbound traffic to https
resource "aws_network_acl_rule" "allow_https_outbound_pvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 111
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"  
  from_port      = 443
  to_port        = 443
}
# allow inbound traffic from db

resource "aws_network_acl_rule" "allow_db_inbound" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 120
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = false
  cidr_block     = "172.16.0.0/16"  
  from_port      = 3306
  to_port        = 3306
}

# allow  outbound to db
resource "aws_network_acl_rule" "allow_db_outbound_pvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 121
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = true
  cidr_block     = "172.16.0.0/16"  
  from_port      = 3306
  to_port        = 3306
}

# allow inbound ssh
resource "aws_network_acl_rule" "allow_pvtssh_inbound" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 130
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = false
  cidr_block     = "10.0.0.0/16"  
  from_port      = 22
  to_port        = 22
}

# allow outbound ssh to db
resource "aws_network_acl_rule" "allow_ssh_outbound_pvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 131
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = true
  cidr_block     = "172.16.0.0/16"  
  from_port      = 22
  to_port        = 22
}

# Allow inbound (vpc peering)
resource "aws_network_acl_rule" "allow_vpc_peering_inbound_devpvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 140
  protocol       = "tcp"
  rule_action    = "allow"
  egress         = false
  cidr_block     = "172.16.0.0/16"
  from_port      = 0
  to_port        = 65535
}

# vpc peering outbound

resource "aws_network_acl_rule" "allow_vpc_peering_outbound_pvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 141
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = true
  cidr_block     = "172.16.0.0/16"  
  from_port      = 0
  to_port        = 65535
}

#inbound ephermal
resource "aws_network_acl_rule" "allow_ephermal__inbound_devpvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 150
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = false
  cidr_block     = "0.0.0.0/0"  
  from_port      = 1024
  to_port        = 65535
}

# Outbound ephermal

resource "aws_network_acl_rule" "allow_ephemeral_outbound_devpvt" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  rule_number    = 151
  protocol       = "tcp"  # tcp all traffic
  rule_action    = "allow"
  egress         = true
  cidr_block     = "0.0.0.0/0"  
  from_port      = 1024
  to_port        = 65535
}

  # NACL Association with Private Subnet
resource "aws_network_acl_association" "pvt_nacl_association" {
  network_acl_id = aws_network_acl.pvt_subnet_nacl.id
  subnet_id      = aws_subnet.pvt_sub1.id  # Replace with your subnet resource

  depends_on = [aws_network_acl.pvt_subnet_nacl, aws_subnet.pvt_sub1]
}


# Public Security Group
resource "aws_security_group" "mysec" {
  name        = "dev_security_grp"
  description = "Dev security group for public access"
  vpc_id      = aws_vpc.Development.id

  # Ingress rules for public access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule for all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "my_sec"
  }
}

# Private Security Group
resource "aws_security_group" "pvt_mysec" {
  name        = "dev_pvt_security_grp"
  description = "Dev private security group"
  vpc_id      = aws_vpc.Development.id

  # Egress rule for all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "pvt_my_sec"
  }
}

# Ingress rule for Private Security Group allowing HTTP from NLB
resource "aws_security_group_rule" "pvt_http_from_nlb" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.pvt_mysec.id
  source_security_group_id = aws_security_group.nlb_mysec.id
}

# NLB Security Group
resource "aws_security_group" "nlb_mysec" {
  name        = "nlb_security_grp"
  description = "NLB security group"
  vpc_id      = aws_vpc.Development.id

  # Ingress rule for HTTP (port 80)
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress rule for all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nlb_my_sec"
  }
}

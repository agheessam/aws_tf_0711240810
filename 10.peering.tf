# Create the VPC Peering Connection
resource "aws_vpc_peering_connection" "dev_to_prod" {
  vpc_id        = aws_vpc.Development.id
  peer_vpc_id   = aws_vpc.Production.id
  auto_accept   = true  # Set to true if you want to automatically accept the connection

  tags = {
    Name = "DevToProdPeering"
  }
}

# Step 2: Enable DNS resolution from Development to Production VPC
resource "aws_vpc_peering_connection_options" "requester_options" {
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_prod.id
  requester {
    allow_remote_vpc_dns_resolution = true    # Allows development VPC to resolve production DNS
  }
}
# Enable DNS resolution from Production to Development VPC
resource "aws_vpc_peering_connection_options" "accepter_options" {
  vpc_peering_connection_id = aws_vpc_peering_connection.dev_to_prod.id
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
}

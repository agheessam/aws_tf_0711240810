#Network Load Balancer
#4.	Create a Network Load Balancer (Name: PRT) and configure it to forward traffic to all instances. 
#Display the output of each instance's web page when accessed through the NLB.

#define the network load balancer
resource "aws_lb" "PRT" {
  name               = "devlopment-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.pub_sub1.id,aws_subnet.pub_sub2.id,aws_subnet.pvt_sub1.id] #keep only pub subnet

  enable_deletion_protection = false
  enable_cross_zone_load_balancing = true
  
  security_groups    = [aws_security_group.nlb_mysec.id]       # Associate the security group with the NLB

  tags = {
    Environment = "development_nlb"
  }
}

# define the target group for the instance 

resource "aws_lb_target_group" "tg_nlb" {
  name     = "tf-nlb-tg"
  port     = 80
  protocol = "TCP"
  vpc_id   = aws_vpc.Development.id
  target_type = "ip"
  
  health_check { 
   protocol = "HTTP"
    port     = "80"
    path     = "/"  # Health check path
    interval = 30              # Interval in seconds
    timeout  = 5               # Timeout in seconds
    healthy_threshold = 2      # Number of successful checks before healthy
    unhealthy_threshold = 2    # Number of failed checks before unhealthy
  }
}

resource "aws_lb_target_group_attachment" "Public1" {
  target_group_arn = aws_lb_target_group.tg_nlb.arn
  target_id        = aws_instance.Public1.private_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "Public2" {
 target_group_arn = aws_lb_target_group.tg_nlb.arn
  target_id        = aws_instance.Public2.private_ip
  port             = 80
}

resource "aws_lb_target_group_attachment" "Private1" {
 target_group_arn = aws_lb_target_group.tg_nlb.arn
  target_id        = aws_instance.Private1.private_ip
  port             = 80
}

#define target group listener

resource "aws_lb_listener" "prt_listener" {
  load_balancer_arn = aws_lb.PRT.arn
  port              = "80"
  protocol          = "TCP"
  #ssl_policy        = "ELBSecurityPolicy-2016-08"# is required for https(443 port)
  #certificate_arn   = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"
  # is required for https(443 port)to establish an SSL/TLS connection

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg_nlb.arn
  }
}

#2.	Launch an instance in each subnet (Name: Public1, Public2, Private1) with Amazon Linux, Ubuntu, RedHat AMIs respectively.
#3.	Install web server in all instances and change the default webpage of the web server with their Private IP being displayed.

#instance with webapp

resource "aws_instance" "Public1" {
  ami                     = "ami-06b21ccaeff8cd686"    #amazon linux
  instance_type           = "t2.micro"
   subnet_id     = aws_subnet.pub_sub1.id
   security_groups = [aws_security_group.mysec.id]
   associate_public_ip_address = true  # Ensures instance gets a public IP
    key_name = "key3"
   user_data = <<-EOF
                   #!/bin/bash
				   sudo yum update -noplugins
				   sudo yum install -y httpd
				   echo "<html><body><h1>Your private ip : $(hostname -I | awk '{print $1}')</h1></body></html>" | sudo tee /var/www/html/index.html
				   sudo systemctl start httpd
				   sudo systemctl enable httpd
				   EOF
   tags = {
    Name = "Public1"
  }

 lifecycle {
    ignore_changes = [user_data]
  }
    depends_on = [aws_security_group.mysec]
}

resource "aws_instance" "Public2" {
  ami                     = "ami-0866a3c8686eaeeba"   #Ubuntu
  instance_type           = "t2.micro"
   subnet_id     = aws_subnet.pub_sub2.id
   security_groups = [aws_security_group.mysec.id]
   associate_public_ip_address = true  # Ensures instance gets a public IP
   key_name = "key3"
   user_data = <<-EOF
                    #!/bin/bash
					sudo apt-get update -y
					sudo apt install -y apache2
					echo "<html><body><h1>Your private ip is : $(hostname -I | awk '{print $1}')</h1></body></html>" | sudo tee /var/www/html/index.html
					sudo systemctl start apache2
					sudo systemctl enable apache2
					EOF
						
    tags = {
    Name = "Public2"
  }

 lifecycle {
    ignore_changes = [user_data]
  }
    depends_on = [aws_security_group.mysec]
}

resource "aws_instance" "Private1" {
  ami                     = "ami-0583d8c7a9c35822c"  # RedHat
  instance_type           = "t2.micro"
   subnet_id     = aws_subnet.pvt_sub1.id
   security_groups = [aws_security_group.mysec.id]
    key_name = "key3"
   user_data = <<-EOF
                    #!/bin/bash
					sudo yum update -noplugins
					sudo yum install -y httpd
					echo "<html><body><h1>your ip address  is : $(hostname -I | awk '{print $1}')</h1></body></html>" | sudo tee /var/www/html/index.html
				    sudo systemctl start httpd
					sudo systemctl enable httpd
					EOF
       tags = {
    Name = "Private1"
  } 
 lifecycle {
    ignore_changes = [user_data]
  }
    depends_on = [aws_security_group.pvt_mysec]
}

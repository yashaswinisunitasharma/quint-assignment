# VPC - Creation

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# IGW - Creation
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

data "aws_availability_zones" "available_zones" {}

#subnet - creation

#public-subnet-1
resource "aws_subnet" "pub_sub_1a"{
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.pub_sub_1a_cidr
    availability_zone = data.aws_availability_zones.available_zones.names[0]
    map_public_ip_on_launch = true

    tags = {
      name = "pub_sub_1a"
    }

}

#public-subnet-2
resource "aws_subnet" "pub_sub_2a"{
    vpc_id = aws_vpc.vpc.id
    cidr_block = var.pub_sub_2a_cidr
    availability_zone = data.aws_availability_zones.available_zones.names[1]
    map_public_ip_on_launch = true

    tags = {
      name = "pub_sub_2a"
    }

}

# RouteTable - Creation

#RT-1
resource "aws_route_table" "RTpub-sub-1a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RTpub-sub-1a"
  }
}

#associating routable -1 with subnet -1
resource "aws_route_table_association" "rtassociation-sub-1a" {
    subnet_id      = aws_subnet.pub_sub_1a.id
    route_table_id = aws_route_table.RTpub-sub-1a.id
}

#RT-2
resource "aws_route_table" "RTpub-sub-2a" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "RTpub-sub-2a"
  }
}

#associating routable -2 with subnet -2
resource "aws_route_table_association" "rtassociation-sub-2a" {
    subnet_id      = aws_subnet.pub_sub_2a.id
    route_table_id = aws_route_table.RTpub-sub-2a.id
}

#creating a security group for subnets
resource "aws_security_group" "ec2-SG" {
  name        = "new-ec2-SG"
  description = "web inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
     
  }

    ingress {
    description      = "SSH from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

    ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
   
  }

  tags = {
    Name = "ec2-SG"
  }
}

#creating network interface for subnet-1 instances

resource "aws_network_interface" "myNIC-sub-1a" {
  subnet_id       = aws_subnet.pub_sub_1a.id 
  security_groups = [aws_security_group.ec2-SG.id]

  tags = {
    name = "myNIC-sub-1"
  }
 
}


#creating network interface for subnet-2 instances

resource "aws_network_interface" "myNIC-sub-2a" {
  subnet_id       = aws_subnet.pub_sub_2a.id
  security_groups = [aws_security_group.ec2-SG.id]

    tags = {
    name = "myNIC-sub-2a"
  }
 
}
 
resource "aws_instance" "ubuntu-1" {

  tags = {Name = "ubuntu-1a"}

  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  availability_zone = "us-east-1a"
  #security_groups = [aws_security_group.myec2-ec2-SG.id]

  key_name = "mykeypair"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.myNIC-sub-1a.id
  }

  # user_data = <<-EOF
	# 	#! /bin/bash
  #   sudo apt-get update -y
	# 	sudo apt-get install -y apache2
	# 	sudo systemctl start apache2
	# 	sudo systemctl enable apache2
	# 	echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
	# EOF
 
}


resource "aws_instance" "ubuntu-2a" {

  tags = {Name = "ubuntu-2a"}
  ami           = "ami-0c7217cdde317cfec"
  instance_type = "t2.micro"
  availability_zone = "us-east-1b"
  #security_groups = [aws_security_group.myec2-ec2-SG.id]

  key_name = "mykeypair"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.myNIC-sub-2a.id
  }

  # user_data = <<-EOF
  #       #!/bin/bash
  #       sudo apt update -y
  #       sudo apt install apache2 -y
  #       sudo systemctl start apache2
  #       sudo bash -c 'echo my first server > /var/www/html/index.html'
  #       EOF  
 
}


#creating Auto-Scaling-Group

resource "aws_autoscaling_group" "quint-asg" {
  name                 = "quint-asg"
  desired_capacity     = 2
  max_size             = 5
  min_size             = 2
  vpc_zone_identifier = [aws_subnet.pub_sub_1a.id, aws_subnet.pub_sub_2a.id]  

  launch_template {
    id      = "lt-005f3572184004e49"   
    version = "$Latest"   
  }

  health_check_type          = "ELB"
  health_check_grace_period  = 300
  force_delete                = true

  tag {
    key                 = "Name"
    value               = "quint-asg"
    propagate_at_launch = true
  }

  target_group_arns = [var.alb_target_group_arn]
 
}

resource "aws_autoscaling_policy" "asg_scale_up_policy" {
  name                   = "asg"
  autoscaling_group_name = aws_autoscaling_group.quint-asg.name
  adjustment_type       = "ChangeInCapacity"
  scaling_adjustment    = 1
  cooldown              = 300
  estimated_instance_warmup = 300
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 80
  }
}

resource "aws_autoscaling_policy" "asg_scale_down_policy" {
  name                   = "asg"
  autoscaling_group_name = aws_autoscaling_group.quint-asg.name
  adjustment_type       = "ChangeInCapacity"
  scaling_adjustment    = -1
  cooldown              = 300
  estimated_instance_warmup = 300
  target_tracking_configuration{
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
  target_value = 20
  
  }
 
} 



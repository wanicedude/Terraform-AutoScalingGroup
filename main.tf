provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "Terra_Traffic_VPC" {
  cidr_block = var.cidr_block
  tags = {
    Name = "Project VPC"
  }
}


# Create Subnets
resource "aws_subnet" "Terra_Traffic_subnets" {
  vpc_id            = aws_vpc.Terra_Traffic_VPC.id
  count             = length(var.subnet_cidr_block)
  cidr_block        = element(var.subnet_cidr_block, count.index)
  availability_zone = element(var.azs, count.index)

  tags = {
    Name = element(var.subnet_tags, count.index)
  }
}

# Create Security Group
resource "aws_security_group" "Terra_Autoscaling_sg" {
  name        = "Terra_Autoscaling_sg"
  description = "Terra_Autoscaling Security Group"
  vpc_id      = aws_vpc.Terra_Traffic_VPC.id

  ingress {
    description = "Allow Inbound HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Terra_Autoscaling-sg"
  }
}

# Create Internet Gateway 
resource "aws_internet_gateway" "Terra_TrafficIGateW" {
  vpc_id = aws_vpc.Terra_Traffic_VPC.id

  tags = {
    Name = "TerraTrafficIGW"
  }
}

#Create Route Table
resource "aws_route_table" "Terra_TRAFFICRoute_T" {
  vpc_id = aws_vpc.Terra_Traffic_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Terra_TrafficIGateW.id
  }

  tags = {
    Name = "TerraTRafficGateway"
  }
}


#Associate Route Table with Subnets
resource "aws_route_table_association" "Terra_RouteTA" {
  count          = 2
  subnet_id      = aws_subnet.Terra_Traffic_subnets[count.index].id
  route_table_id = aws_route_table.Terra_TRAFFICRoute_T.id
}


#Create a Launch Template
resource "aws_launch_template" "TTEMPLATE" {
  name = "TerraTeamplate"
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 8
      volume_type = "gp2"
    }
  }

  image_id = var.instance_ami
  key_name = "Lala"

  instance_type = "t2.micro"
  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.Terra_Autoscaling_sg.id]
  }
  placement {
    availability_zone = "us-east-1"
  }

  # vpc_security_group_ids = [aws_security_group.Terra_Autoscaling_sg.id]
  user_data = filebase64("${path.module}/userdata.sh")


}


#Create Auto Scaling Group
resource "aws_autoscaling_group" "TerraAutoSG" {
  vpc_zone_identifier = aws_subnet.Terra_Traffic_subnets.*.id
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2

  launch_template {
    id      = aws_launch_template.TTEMPLATE.id
    version = "$Latest"
  }
}
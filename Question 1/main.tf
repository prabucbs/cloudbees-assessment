provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

# Create public subnet A
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

# Create public subnet B
resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
}

# Create private subnet A
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
}

# Create private subnet B
resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
}

# Create route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

# Associate public subnets with public route table
resource "aws_route_table_association" "public_subnet_a_association" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_b_association" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "my_security_group" {
  name        = "my-security-group"
  description = "Allow inbound traffic"
  vpc_id      = aws_vpc.my_vpc.id
}

resource "aws_lb" "my_alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_security_group.id] 

  subnets = [
    aws_subnet.public_subnet_a.id,
    aws_subnet.public_subnet_b.id,
  ]

  enable_deletion_protection = false
}

# EC2 Instances
resource "aws_instance" "ec2_instance_a" {
  ami           = "ami-051f8a213df8bc089" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_a.id
  key_name      = "my-key-pair" 
  tags = {
    Name = "EC2 Instance A"
  }

  vpc_security_group_ids = [aws_security_group.my_security_group.id] 
}

resource "aws_instance" "ec2_instance_b" {
  ami           = "ami-051f8a213df8bc089"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_b.id
  key_name      = "my-key-pair"
  tags = {
    Name = "EC2 Instance B"
  }

  vpc_security_group_ids = [aws_security_group.my_security_group.id]
}

# Database Subnet Group
resource "aws_db_subnet_group" "private_subnet_group" {
  name       = "my-private-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
}

resource "aws_db_instance" "mysql_instance_a" {
  engine               = "mysql"
  instance_class       = "db.t3.micro" 
  allocated_storage    = 10
  storage_type         = "gp2"
  engine_version       = "5.7"         
  username             = "admin"
  password             = "password" 
  db_subnet_group_name = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_security_group.id] 
}

resource "aws_db_instance" "mysql_instance_b" {
  engine               = "mysql"
  instance_class       = "db.t3.micro" 
  allocated_storage    = 10
  storage_type         = "gp2"
  engine_version       = "5.7"         
  username             = "admin"
  password             = "password" 
  db_subnet_group_name = aws_db_subnet_group.private_subnet_group.name
  vpc_security_group_ids = [aws_security_group.my_security_group.id]
}
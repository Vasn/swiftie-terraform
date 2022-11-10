# 1. Create 1x VPC
resource "aws_vpc" "swiftie_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "swiftie_vpc"
  }
}
# 2. Create 2x subnet (1 public, 1 private)
resource "aws_subnet" "swiftie_public_subnet" {
  vpc_id                  = aws_vpc.swiftie_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "swiftie_subnet_public"
  }
}

resource "aws_subnet" "swiftie_private_subnet" {
  vpc_id                  = aws_vpc.swiftie_vpc.id
  cidr_block              = "10.123.2.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"

  tags = {
    Name = "swiftie_subnet_private"
  }
}

# 3. Create IGW
resource "aws_internet_gateway" "swiftie_igw" {
  vpc_id = aws_vpc.swiftie_vpc.id

  tags = {
    Name = "swiftie_igw"
  }
}

# 4. Create custom route table + route
resource "aws_route_table" "swiftie_public_rt" {
  vpc_id = aws_vpc.swiftie_vpc.id

  tags = {
    Name = "swiftie_public_rt"
  }
}

resource "aws_route" "swiftie_default_route" {
  route_table_id         = aws_route_table.swiftie_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.swiftie_igw.id
}

# 5. Associate subnet with route table
resource "aws_route_table_association" "swiftie_public_assoc" {
  subnet_id      = aws_subnet.swiftie_public_subnet.id
  route_table_id = aws_route_table.swiftie_public_rt.id
}

# 6. Create security group to allow web traffic & SSH (port 22, 80, 443)
resource "aws_security_group" "swiftie_allow_web" {
  name        = "swiftie_allow_web_traffic"
  description = "Allow inbound web traffic"
  vpc_id      = aws_vpc.swiftie_vpc.id

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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
    Name = "allow_web"
  }
}

resource "aws_security_group" "swiftie_backend" {
  name        = "swiftie_backend"
  description = "Allow inbound frontend traffic"
  vpc_id      = aws_vpc.swiftie_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 5000
    to_port     = 5020
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
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
    Name = "allow_backend"
  }
}

# 7. Create a network interface with ip in subnet (in step 2)
resource "aws_network_interface" "swiftie_server_nic" {
  subnet_id       = aws_subnet.swiftie_public_subnet.id
  private_ips     = ["10.123.1.50"]
  security_groups = [aws_security_group.swiftie_allow_web.id]
}

resource "aws_eip" "one" {
  vpc                       = true
  network_interface         = aws_network_interface.swiftie_server_nic.id
  associate_with_private_ip = "10.123.1.50"
  depends_on                = [aws_internet_gateway.swiftie_igw]
}

# 8. Create webserver & apache
resource "aws_key_pair" "swiftie_auth" {
  key_name   = "swiftie-key"
  public_key = file("~/.ssh/swiftiekey.pub")
}

resource "aws_instance" "swiftie_web_server_instance" {
  ami               = data.aws_ami.server_ami.id
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = aws_key_pair.swiftie_auth.key_name

  network_interface {
    network_interface_id = aws_network_interface.swiftie_server_nic.id
    device_index         = 0
  }

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo sytemtl start apache2
              sudo bash -c 'echo your very firrst webserver > /var/www/html/index.html'
              EOF

  tags = {
    Name = "web-server"
  }
}

resource "aws_instance" "swiftie_backend_server_loans" {
  ami               = data.aws_ami.server_ami.id
  instance_type     = "t2.micro"
  availability_zone = "us-east-1a"
  key_name          = aws_key_pair.swiftie_auth.key_name
  subnet_id = aws_subnet.swiftie_public_subnet.id

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update &&
              sudo apt-get install -y \ 
              python3
              pip install Flask
              EOF

  tags = {
    Name = "backend-loans-server"
  }
}


# 9. Create Route 53
# 10. Create WAF
# 11. Create API gateway
# 12. Create ELB
# 13. Create ALB
# 14. Create Router
# 15. Create backend flask
# 16. Create auto scaling group
# 17. Create DynamoDB
# 18. Create Datapipeline
# 19. Create S3 for pipeline
# 20. Create Lambda for GCP backup
# 21. Create Storage Transfer Service (GCP)
# 22. Create Cloud Storage (GCP)
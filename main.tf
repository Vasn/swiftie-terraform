# Create a VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.region}-vpc"
  }
}

# Create an internet gateway for public subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  }
}

# Elastic IP for NAT
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
}

# Create a Network Address Translation (NAT) Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.igw]
  tags = {
    Name        = "nat"
    Environment = var.environment
  }
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${var.availability_zone}-public-subnet",
    Environment = var.environment
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.123.10.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "swift-us-east-1b-public-subnet",
    Environment = var.environment
  }
}

# Create a private subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.environment}-${var.availability_zone}-private-subnet"
    Environment = var.environment
  }
}

# Route table for private subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-private-route-table"
    Environment = var.environment
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

# Routes
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(var.private_subnets_cidr)
  subnet_id      = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

/* ==== VPC's Default Security Group ====== */
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = aws_vpc.vpc.id
  depends_on  = [aws_vpc.vpc]
  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }
  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "allow_web" {
  name        = "allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.vpc.id

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

# EC2 instances

resource "aws_network_interface" "nic" {
  subnet_id       = aws_subnet.public_subnet[0].id
  private_ips     = ["10.123.1.50"]
  security_groups = [aws_security_group.allow_web.id]

  tags = {
    Name = "pub_network_interface"
  }
}

resource "aws_instance" "web_server" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = var.key_pair_name
  # security_groups = [aws_security_group.allow_web.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo apt install php libapache2-mod-php -y
              sudo sytemtl start apache2
              sudo bash -c 'echo your very 2nd webserver > /var/www/html/index.html'
              sudo chown -R ubuntu:ubuntu /var/www/html
              sudo chmod -R 755 /var/www/html
              EOF

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic.id
  }

  tags = {
    Name = "ubuntu_web_server"
  }
}

resource "aws_network_interface" "nic_2" {
  subnet_id       = aws_subnet.public_subnet_2.id
  private_ips     = ["10.123.10.50"]
  security_groups = [aws_security_group.allow_web.id]

  tags = {
    Name = "pub_network_interface_2"
  }
}

resource "aws_instance" "web_server_2" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  availability_zone = "us-east-1b"
  key_name          = var.key_pair_name
  # security_groups = [aws_security_group.allow_web.id]
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install apache2 -y
              sudo apt install php libapache2-mod-php -y
              sudo sytemtl start apache2
              sudo bash -c 'echo your very 2nd webserver > /var/www/html/index.html'
              sudo chown -R ubuntu:ubuntu /var/www/html
              sudo chmod -R 755 /var/www/html
              EOF

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic_2.id
  }

  tags = {
    Name = "ubuntu_web_server"
  }
}

resource "aws_lb" "front_end" {
  name               = "web-app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_allow_web.id]
  subnets            = [aws_subnet.public_subnet[0].id, aws_subnet.public_subnet_2.id]

  tags = {
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "front_end" {
  name     = "front-end-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_target_group_attachment" "front_end_instance_1" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.web_server.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "front_end_instance_2" {
  target_group_arn = aws_lb_target_group.front_end.arn
  target_id        = aws_instance.web_server_2.id
  port             = 80
}

resource "aws_lb_listener_rule" "static" {
  listener_arn = aws_lb_listener.front_end.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end.arn
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  # condition {
  #   host_header {
  #     values = ["example.com"]
  #   }
  # }
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.front_end.arn
  port              = "80"
  protocol          = "HTTP"

  # default_action {
  #   type             = "forward"
  #   target_group_arn = aws_lb_target_group.front_end.arn
  # }

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: Page is not found"
      status_code  = 404
    }
  }
}

resource "aws_security_group" "alb_allow_web" {
  name        = "alb_allow_web"
  description = "Allow web inbound traffic"
  vpc_id      = aws_vpc.vpc.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_allow_web"
  }
}

resource "aws_route53_zone" "primary" {
  name = "swiftiebank.link"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "swiftiebank.link"
  type    = "A"

  alias {
    name                   = aws_lb.front_end.dns_name
    zone_id                = aws_lb.front_end.zone_id
    evaluate_target_health = true
  }

}

resource "aws_security_group" "allow_backend" {
  name        = "allow_backend"
  description = "Allow inbound frontend traffic"
  vpc_id      = aws_vpc.vpc.id

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

resource "aws_network_interface" "nic_private" {
  subnet_id       = aws_subnet.private_subnet[0].id
  count           = length(var.private_ips)
  private_ips     = element(var.private_ips, count.index)
  security_groups = [aws_security_group.allow_backend.id]

  tags = {
    Name = "private_network_interface"
  }
}

# Private Instances
resource "aws_instance" "api_server" {
  ami               = data.aws_ami.ubuntu.id
  instance_type     = var.instance_type
  availability_zone = var.availability_zone
  key_name          = var.key_pair_name
  count             = length(var.backend_instance_names)

  user_data = <<-EOF
              #!/bin/bash
              sudo apt update -y
              sudo apt install python3-pip -y
              sudo apt install python3-venv pip -y
              sudo chown -R ubuntu:ubuntu /flask_application
              sudo chmod -R 755 /flask_application
              sudo iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 5000
              mkdir flask_application
              cd flask_application
              python3 -m venv venv
              source venv/bin/activate
              EOF

  network_interface {
    device_index         = 0
    network_interface_id = aws_network_interface.nic_private[count.index].id
  }

  tags = {
    Name = "${element(var.backend_instance_names, count.index)}-ubuntu-api-server"
  }
}
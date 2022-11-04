resource "aws_vpc" "swiftie_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "swiftie_vpc"
  }
}

resource "aws_subnet" "swiftie_public_subnet" {
  vpc_id                  = aws_vpc.swiftie_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "swiftie_subnet_public"
  }
}

resource "aws_internet_gateway" "swiftie_igw" {
  vpc_id = aws_vpc.swiftie_vpc.id

  tags = {
    Name = "swiftie_igw"
  }
}

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

resource "aws_route_table_association" "swiftie_public_assoc" {
  subnet_id      = aws_subnet.swiftie_public_subnet.id
  route_table_id = aws_route_table.swiftie_public_rt.id
}

resource "aws_security_group" "swiftie_sg" {
  name        = "swiftie_sg"
  description = "Swiftie Security Group"
  vpc_id      = aws_vpc.swiftie_vpc.id

  ingress {
    description = "TLS from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_key_pair" "swiftie_auth" {
  key_name   = "swiftie-key"
  public_key = file("~/.ssh/swiftiekey.pub")
}

resource "aws_instance" "swiftie_node" {
  instance_type = "t2.micro"
  ami = data.aws_ami.server_ami.id
  key_name = aws_key_pair.swiftie_auth.key_name
  vpc_security_group_ids = [aws_security_group.swiftie_sg.id]
  subnet_id = aws_subnet.swiftie_public_subnet.id
  user_data = file("userdata.tpl")

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "swiftie_node"
  }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ubuntu",
      identityfile = "~/.ssh/swiftiekey"
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
}
# variable "region" {
#   type    = string
#   description = "AWS deployment region..."
#   default = "us-east-1"
# }

variable "region" {
  type        = string
  description = "AWS deployment region..."
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "The Deployment environment"
}

//Networking
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "availability_zone" {
  type        = string
  description = "The az that the resources will be launched"
}

variable "instance_type" {
  type        = string
  description = "The instance type that will be provisioned for EC2 instance"
}

variable "key_pair_name" {
  type        = string
  description = "Key Pair name on AWS"
}

variable "backend_instance_names" {
  type        = list(any)
  description = "The instance names for all backend instances"
}

variable "private_ips" {
  type        = list(any)
  description = "Private Ips for network interface"
}
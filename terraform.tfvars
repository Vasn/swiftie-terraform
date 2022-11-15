region      = "us-east-1"
environment = "swift"

/* module networking */
vpc_cidr             = "10.123.0.0/16"
public_subnets_cidr  = ["10.123.1.0/24"] //List of Public subnet cidr range
private_subnets_cidr = ["10.123.2.0/24"] //List of private subnet cidr range
availability_zone    = "us-east-1a"

/* backend instances */
instance_type          = "t2.micro"
key_pair_name          = "v-main-key"
backend_instance_names = ["payments", "customers", "loans", "deposits"]
private_ips            = [["10.123.2.50"], ["10.123.2.51"], ["10.123.2.52"], ["10.123.2.53"]]
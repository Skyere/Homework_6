
variable aws_reg {
  default     = "us-east-1"
}

variable project {
  description = "this is name for tags"
  default     = "wordpress"
}

variable username {
  description = "DB username"
}

variable password {
  description = "DB password"
}

variable dbname {
  description = "db name"
}

variable ssh_key {
  default     = "./type your public key here"
  description = "Default pub key"
}

variable ssh_priv_key {
  default     = "./type your private key here"
  description = "Default private key"
}

variable vpc_cidr  {
  default     = "10.0.0.0/16"
}

variable public_subnet_cidrs {
  default     = [ "10.0.1.0/24","10.0.2.0/24","10.0.3.0/24" ]
}

variable private_subnet_cidrs {
  default     = [ "10.0.10.0/24","10.0.20.0/24","10.0.30.0/24" ]
}
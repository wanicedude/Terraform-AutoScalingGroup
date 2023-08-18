variable "region" {
  type    = string
  default = "us-east-1"
}

variable "cidr_block" {
  type    = string
  default = "174.10.12.0/24"
}

variable "azs" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "subnet_cidr_block" {
  type    = list(string)
  default = ["174.10.12.0/25", "174.10.12.128/25"]
}

variable "subnet_tags" {
  type    = list(string)
  default = ["1st subnet", "2nd subnet"]
}

variable "instance_ami" {
  type    = string
  default = "ami-08a52ddb321b32a8c"
}
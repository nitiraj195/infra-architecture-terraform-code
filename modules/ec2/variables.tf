variable "instance_type" {}
variable "region" {}
variable "vpc_cidr" {
  type  = string
}
variable "blacklisted_az" {
  default = ["us-east-1a", "us-east-1b","us-east-1e", "us-east-1f", "ap-south-1c"]
}
variable "public_sg_ports" {
  type = list(number)
  default = [22,80,443]
}
variable "private_sg_ports" {
  type = list(number)
  default = [22,3306]
}

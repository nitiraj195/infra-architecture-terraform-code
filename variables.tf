variable "instance_type" {
  type = string
}
/*
variable "region" {
  type = list(string)
}
*/
variable "vpc_cidr" {
  type = list(string)
  default = ["192.168.0.0/16", "10.0.0.0/16"]
}

// EC2 for twitter scraper

variable "network_interface_id" {
  type = string
  default = "network_id_from_aws"
}

variable "ami" {
    type = string
    default = "ami-02b01316e6e3496d9"
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}
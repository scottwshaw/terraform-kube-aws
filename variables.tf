variable "aws_key_path" {}
variable "aws_key_name" {}
variable "aws_profile" {}

variable "aws_region" {
    description = "EC2 Region for the VPC"
    default = "ap-southeast-2"
}

variable "amis" {
    description = "AMIs by region"
    default = {
        eu-west-1 = "ami-f1810f86" # ubuntu 14.04 LTS
        ap-southeast-2 = "ami-0ad923ecd2b2e245b" # ubuntu xenial 16.04 LTS
    }
}

variable "vpc_cidr" {
    description = "CIDR for the whole VPC"
    default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
    description = "CIDR for the Public Subnet"
    default = "10.0.0.0/24"
}

variable "private_subnet_cidr" {
    description = "CIDR for the Private Subnet"
    default = "10.0.1.0/24"
}

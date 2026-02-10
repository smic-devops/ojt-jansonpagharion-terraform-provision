variable "region" {
  description = "AWS region singapore"
  type        = string
  default     = "ap-southeast-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_type" {
  type        = string
  description = "Ubuntu AMI ID"
  default     = "ami-0d6621c01e8c2de2a"
}

# VPC ID

variable "vpc" {
  type        = string
  description = "VPC ID"
  default     = "vpc-05596861f4ecffdeb"

}

# Subnets

variable "subnetpublic1" {
  type        = string
  description = "Public Subnet 1 ID"
  default     = "subnet-02f95b7899e8bed30"
}

variable "subnetpublic2" {
  type        = string
  description = "Public Subnet 2 ID"
  default     = "subnet-09c8dbaa942884f5d"
}

variable "subnetprivate" {
  type        = string
  description = "Private Subnet ID"
  default     = "subnet-0ee426ba08e9643d9"
}


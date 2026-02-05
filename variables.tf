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
  default     = "vpc-0cb1c79de3EXaMplE"

}

# Subnets

variable "subnetpublic1" {
  type        = string
  description = "Public Subnet 1 ID"
  default     = "aws_subnet.public.id"
}

variable "subnetpublic2" {
  type        = string
  description = "Public Subnet 2 ID"
  default     = "aws_subnet.co_public.id"
}

variable "subnetprivate" {
  type        = string
  description = "Private Subnet ID"
  default     = "aws_subnet.private.id"
}


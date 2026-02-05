variable "region" {
  description = "AWS region sydney"
  type        = string
  default     = "ap-southeast-2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_type" {
  type        = string
  description = "Ubuntu AMI ID"
  default     = "ami-0d6621c01e8c2de2c"
}

variable "vpc" {
  type = string
  description = "VPC ID"
  default = "vpc-0bb1c79de3EXAMPLE"
  
}
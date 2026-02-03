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
  default     = "ami-0d6621c01e8c2de2c" # Ubuntu Server 20.04 LTS (HVM), SSD Volume Type
}

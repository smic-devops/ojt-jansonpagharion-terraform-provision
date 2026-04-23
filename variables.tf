variable "vpc_id" {
  description = "Existing VPC ID"
  type        = string
  default     = "vpc-05596861f4ecffdeb"
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB (one per AZ)"
  type        = list(string)
  default = [
    "subnet-09c8dbaa942884f5d",
    "subnet-02f95b7899e8bed30"
  ]
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for EC2 instances (one per AZ)"
  type        = list(string)
  default = [
    "subnet-0ee426ba08e9643d9",
    "subnet-095cdc7b816291369"
  ]
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
  default     = "ami-03c3282f979a6a9b0"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
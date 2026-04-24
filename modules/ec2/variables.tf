variable "vpc_id" {
  description = "VPC ID where EC2 instances are deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs (one per AZ)"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "alb_security_group_id" {
  description = "ALB security group ID allowed to access EC2"
  type        = string
}
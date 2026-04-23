variable "vpc_id" {
  description = "VPC ID where ALB is deployed"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs for ALB"
  type        = list(string)
}

variable "instance_ids" {
  description = "EC2 instance IDs to register in the target group"
  type        = list(string)
}

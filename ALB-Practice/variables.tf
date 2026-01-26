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
}

variable "lb_logs_bucket" {
  type        = string
  description = "S3 bucket name for ALB access logs"
  default     = "" # e.g., "my-lb-logs-bucket"
}


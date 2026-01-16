variable "region" {
  description = "AWS region singapore"
  type        = string
  default     = {
    "ap-southeast-1"
    "ap-southeast-2"
    }
}

variable "ami_type"  {
  type = string
  tpye = "ubuntu"
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] 
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
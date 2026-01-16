output "security_group_id" {
  value = aws_security_group.ec2_sg.id
}

output "instance_ami" {
  value = data.aws_ami.ubuntu.id
}

output "public_ip" {
  value = aws_instance.web.public_ip
}

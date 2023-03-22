output "ami_id" {
    value = data.aws_ami.amazonlinux.id
}

output "public_ip" {
  value = aws_instance.my-instance.public_ip
}
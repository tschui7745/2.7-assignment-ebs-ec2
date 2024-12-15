output "vpc_id" {
  value = data.aws_vpc.vpc_id.id
}

output "public_subnet_id" {
  value = aws_instance.amazon_linux_ec2.subnet_id
}

output "public_subnet_ids" {
  value = data.aws_subnets.public.ids
}

output "ami_id" {
  value = aws_instance.amazon_linux_ec2.id
}

output "ami_name" {
  value = data.aws_ami.amazon_linux.name
}

output "public_ip" {
  value = aws_instance.amazon_linux_ec2.public_ip
}

output "public_dns" {
  value = aws_instance.amazon_linux_ec2.public_dns
}

output "ec2_instance_id" {
  value = data.aws_instance.ec2_instance_id.id
}

output "ec2_instance_availability_zone" {
  value = data.aws_instance.ec2_instance_id.availability_zone
}


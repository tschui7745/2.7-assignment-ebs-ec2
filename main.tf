locals {
  name_prefix = "tschui"
}

/*-Create EC2 Variable-*/

data "aws_vpc" "vpc_id" {
  filter {
    name   = "tag:Name"
    values = ["shared-vpc"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_id.id]
  }
  filter {
    name   = "tag:Name"
    values = ["*-public-*"]
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  # Filter by name or other parameters (e.g., Amazon Linux 2023)
  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"] #al2023-ami-2023.6.20241121.0-kernel-6.1-x86_64
  }
}

/*-Create EC2 Instanace-*/

resource "aws_instance" "amazon_linux_ec2" {
  ami                         = data.aws_ami.amazon_linux.id   # Replace with the Amazon Linux 2023 AMI ID
  instance_type               = "t2.micro"                     # Choose the appropriate instance type
  subnet_id                   = data.aws_subnets.public.ids[0] #Public Subnet ID, e.g. subnet-0088a8912029e13c6 (shared-vpc-public-ap-southeast-1a)
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ec2_security_group.id]

  tags = {
    Name = "${local.name_prefix}-ebs-ec2"
  }
}

/*-Create EC2 Securiy Group-*/

resource "aws_security_group" "ec2_security_group" {
  name        = "${local.name_prefix}-ebs-ec2-sg"
  description = "Allow SSH and HTTPS access"
  vpc_id      = data.aws_vpc.vpc_id.id

  lifecycle {
    create_before_destroy = true
  }

  // Allow SSH from home (replace with your public IP or use CIDR block)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_instance" "ec2_instance_id" {

  instance_id = aws_instance.amazon_linux_ec2.id

  /*
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_id.id]
  }

  filter {
    name   = "tag:Name"
    values = ["${local.name_prefix}-ebs*"]
  }
  */
}

/*-Create EBS Volume-*/

resource "aws_ebs_volume" "ec2_ebs_volume" {
  availability_zone = data.aws_instance.ec2_instance_id.availability_zone # Use the same AZ as EC2 instance
  size              = 1                                                   # Volume size in GiB
  type              = "gp3"                                               # General Purpose SSD
  iops              = 3000                                                # IOPS for gp3
  throughput        = 125                                                 # Throughput for gp3

  tags = {
    Name = "${local.name_prefix}-ebs-volume"
  }
}

/*-Attach the EBS volume to the EC2 instance-*/

resource "aws_volume_attachment" "ec2_ebs_volume_attach" {
  device_name = "/dev/sdb" # You can specify any device name like /dev/sdf, /dev/xvdf, etc.
  volume_id   = aws_ebs_volume.ec2_ebs_volume.id
  instance_id = data.aws_instance.ec2_instance_id.id
}



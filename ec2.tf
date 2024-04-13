# Create EC2 instance with Amzaon Linux 2 AMI and lambton key pair. Attach IAM role with S3 full access and SSM connection access. Install minikube and kubectl on the instance.
resource "aws_instance" "ec2" {
  ami = data.aws_ami_ids.amazon-linux2.ids[0]
  instance_type = "t2.micro"
  key_name = "devops-project"
  subnet_id = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2.id]
  tags = {
    Name = "${var.project_name}-${var.env}-app"
  }

  iam_instance_profile = aws_iam_instance_profile.ec2-s3-ssm.name
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              service docker start
              usermod -a -G docker ec2-user
              EOF
}

# security group for ec2 instance
resource "aws_security_group" "ec2" {
  name = "${var.project_name}-${var.env}-ec2-sg"
  vpc_id = aws_vpc.vpc.id

    egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }

    ingress = [ 
        {
            from_port = 80
            to_port = 80
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "Allow HTTP inbound traffic"
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = true
        },
        {
            from_port = 22
            to_port = 22
            protocol = "tcp"
            cidr_blocks = ["0.0.0.0/0"]
            description = "Allow SSH traffic"
            ipv6_cidr_blocks = []
            prefix_list_ids = []
            security_groups = []
            self = true
        }
    ]
}


data "aws_ami_ids" "amazon-linux2" {
  owners = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-2.0.*-x86_64*"]
  }
}

resource "aws_eip" "eip" {
  instance = aws_instance.ec2.id
  vpc = true
}
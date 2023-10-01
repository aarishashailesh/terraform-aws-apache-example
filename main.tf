
provider "aws" {
  # Configuration options
  region = "us-east-1"
}

data "aws_vpc" "main" {
  id = var.vpc_id
}

data "aws_subnets" "subnet_ids" {
//  vpc_id = data.aws_vpc.main.id
/*  filter {
    name   = "tag:Name"
    values = ["my-subnet-1a", "my-subnet-1b", "my-subnet-1c"] 
  }
*/  
}


resource "aws_security_group" "sg_my_server" {
  name        = "sg_my_server"
  description = "MyServer Security Group"
  vpc_id      = data.aws_vpc.main.id

  ingress = [
    {
      description      = "HTTP"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    },
    {
      description      = "SSH"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["100.36.36.204/32"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }

  ]

  egress {
    description      = "Outgoing Traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }


}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = var.public_key
}

data "template_file" "user_data" {
  template = file("${abspath(path.module)}/userdata.yaml")
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "my_server" {
 // count =  3
  ami                    = data.aws_ami.amazon-linux-2.id
  subnet_id              = data.aws_subnets.subnet_ids.ids[0]
  instance_type          = var.instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = ["${aws_security_group.sg_my_server.id}"]
  user_data              = data.template_file.user_data.rendered



  tags = {
    Name = var.server_name
  }


}
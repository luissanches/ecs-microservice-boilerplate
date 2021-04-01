
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "luis"
}

####### VPC - VIRTUAL PRIVATE CLOUD #######

resource "aws_vpc" "oneedge-vpc" {
  cidr_block           = "168.31.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "oneedge-vpc"
  }
}

resource "aws_subnet" "oneedge-subnet-01" {
  vpc_id            = aws_vpc.oneedge-vpc.id
  cidr_block        = "168.31.0.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "oneedge-subnet-01"
  }
}

resource "aws_subnet" "oneedge-subnet-02" {
  vpc_id            = aws_vpc.oneedge-vpc.id
  cidr_block        = "168.31.16.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name = "oneedge-subnet-02"
  }
}

resource "aws_internet_gateway" "oneedge-ig" {
  vpc_id = aws_vpc.oneedge-vpc.id
  tags = {
    Name = "oneedge-ig"
  }
}

resource "aws_default_route_table" "oneedge-route-table-01" {
  default_route_table_id = aws_vpc.oneedge-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.oneedge-ig.id
  }

  tags = {
    Name = "oneedge-route-table-01"
  }
}


####### ECR - ELASTIC CONTAINER REGISTRY #######

resource "aws_ecr_repository" "one-edge-backend-auth" {
  name                 = "one-edge-backend-auth"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "one-edge-backend-tenants" {
  name                 = "one-edge-backend-tenants"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "one-edge-backend-billing" {
  name                 = "one-edge-backend-billing"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# resource "aws_ecr_repository" "one-edge-backend-fw-security" {
#   name                 = "one-edge-backend-fw-security"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

####### AMAZON DOCUMENT DB #######

# resource "aws_docdb_subnet_group" "one-edge-db-subnet-group" {
#   name       = "one-edge-db-subnet-group"
#   subnet_ids = [aws_subnet.oneedge-subnet-01.id, aws_subnet.oneedge-subnet-02.id]

#   tags = {
#     Name = "My docdb subnet group"
#   }
# }

# resource "aws_docdb_cluster" "one-edge-db-cluster" {
#   cluster_identifier      = "one-edgedb-cluster"
#   availability_zones      = ["us-east-1a", "us-east-1b"]
#   backup_retention_period = 5
#   skip_final_snapshot     = true
#   master_username         = "OneEdgeDBUser"
#   master_password         = "OneEdgeDBPWS"
#   port                    = 27017
#   db_subnet_group_name    = "one-edge-db-subnet-group"
#   engine_version          = "4.0.0"
# }

# resource "aws_docdb_cluster_instance" "one-edge-db-instance" {
#   count              = 1
#   identifier         = "one-edge-db-instance-${count.index}"
#   cluster_identifier = aws_docdb_cluster.one-edge-db-cluster.id
#   instance_class     = "db.t3.medium"
#   engine_version     = "4.0.0"
# }


####### ELB - ELASTIC LOAD BALANCE #######
resource "aws_security_group" "one-edge-ecs-elb-sg" {
  name        = "one-edge-ecs-elb-sg"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.oneedge-vpc.id

  ingress {
    description      = "Http from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "one-edge-ecs-elb-sg"
  }
}

resource "aws_lb" "one-edge-ecs-elb" {
  name               = "one-edge-ecs-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.one-edge-ecs-elb-sg.id]
  subnets            = [aws_subnet.oneedge-subnet-01.id, aws_subnet.oneedge-subnet-02.id]

  enable_deletion_protection = false
  tags = {
    Environment = "one-edge-ecs-elb"
  }
}


####### ECS CLUSTER #######
# resource "aws_security_group" "one-edge-ecs-cluster-sg" {
#   name        = "one-edge-ecs-cluster-sg"
#   description = "Allow ssh inbound traffic"
#   vpc_id      = aws_vpc.oneedge-vpc.id

#   ingress {
#     description      = "Ssh from VPC"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "one-edge-ecs-cluster-sg"
#   }
# }

# data "aws_iam_instance_profile" "iam_instance_profile_tester" {
#   name = "tester"
# }

# resource "aws_launch_configuration" "one-edge-stage-mongodb" {
#   name                        = "one-edge-stage-mongodb"
#   image_id                    = data.aws_ami.amazon_linux_2.id
#   instance_type               = "t2.micro"
#   key_name                    = "test-ec2"
#   associate_public_ip_address = "true"
#   security_groups             = [aws_security_group.one-edge-ec2-mongodb-sg.id]
#   user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.default.name} > /etc/ecs/ecs.config"
# }

# resource "aws_ecs_cluster" "one-edge-ecs-cluster" {
#     name = "one-edge-ecs-cluster"
#     tags = {
#     Name = "one-edge-ecs-cluster"
#   }
# }


####### EC2 MongoDB #######


# resource "aws_security_group" "one-edge-ec2-mongodb-stage-sg" {
#   name        = "one-edge-ec2-mongodb-stage-sg"
#   description = "Allow ssh inbound traffic"
#   vpc_id      = aws_vpc.oneedge-vpc.id

#   ingress {
#     description      = "Ssh from VPC"
#     from_port        = 22
#     to_port          = 22
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   ingress {
#     description      = "Ssh from VPC"
#     from_port        = 27017
#     to_port          = 27017
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "one-edge-ec2-mongodb-stage-sg"
#   }
# }

# data "aws_ami" "amazon_linux_2" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-ebs"]
#   }
# }

# resource "aws_instance" "one-edge-stage-mongodb" {
#   ami                         = data.aws_ami.amazon_linux_2.id
#   instance_type               = "t2.micro"
#   key_name                    = "test-ec2"
#   associate_public_ip_address = "true"
#   security_groups             = [aws_security_group.one-edge-ec2-mongodb-stage-sg.id]
#   subnet_id                   = aws_subnet.oneedge-subnet-01.id
#   user_data                   = "#!/bin/bash\nsudo yum update -y && sudo amazon-linux-extras install docker && sudo yum install docker && sudo service docker start && sudo usermod -a -G docker ec2-user && docker run -d --name 1edge-mongodb --restart=always -e MONGO_INITDB_ROOT_USERNAME=OneEdgeDBUser -e MONGO_INITDB_ROOT_PASSWORD=OneEdgeDBPWS -p 27017:27017 -d mongo"
  
  
#   tags = {
#     Name = "one-edge-stage-mongodb"
#   }
# }

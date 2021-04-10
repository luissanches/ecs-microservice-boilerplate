
provider "aws" {
  region                  = "us-east-1"
  shared_credentials_file = "$HOME/.aws/credentials"
  profile                 = "luis"
}

####### VPC - VIRTUAL PRIVATE CLOUD #######

resource "aws_vpc" "oe-vpc" {
  cidr_block           = "168.31.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "oe-vpc"
  }
}

resource "aws_subnet" "oe-subnet-01" {
  vpc_id            = aws_vpc.oe-vpc.id
  cidr_block        = "168.31.0.0/20"
  availability_zone = "us-east-1a"
  tags = {
    Name = "oe-subnet-01"
  }
}

resource "aws_subnet" "oe-subnet-02" {
  vpc_id            = aws_vpc.oe-vpc.id
  cidr_block        = "168.31.16.0/20"
  availability_zone = "us-east-1b"
  tags = {
    Name = "oe-subnet-02"
  }
}

resource "aws_internet_gateway" "oe-ig" {
  vpc_id = aws_vpc.oe-vpc.id
  tags = {
    Name = "oe-ig"
  }
}

resource "aws_default_route_table" "oe-route-table-01" {
  default_route_table_id = aws_vpc.oe-vpc.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.oe-ig.id
  }

  tags = {
    Name = "oe-route-table-01"
  }
}


####### ECR - ELASTIC CONTAINER REGISTRY #######

resource "aws_ecr_repository" "oe-backend-auth" {
  name                 = "oe-backend-auth"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "oe-backend-tenants" {
  name                 = "oe-backend-tenants"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "oe-backend-billing" {
  name                 = "oe-backend-billing"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# resource "aws_ecr_repository" "oe-backend-fw-security" {
#   name                 = "oe-backend-fw-security"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

####### AMAZON DOCUMENT DB #######

# resource "aws_docdb_subnet_group" "oe-db-subnet-group" {
#   name       = "oe-db-subnet-group"
#   subnet_ids = [aws_subnet.oe-subnet-01.id, aws_subnet.oe-subnet-02.id]

#   tags = {
#     Name = "My docdb subnet group"
#   }
# }

# resource "aws_docdb_cluster" "oe-db-cluster" {
#   cluster_identifier      = "one-edgedb-cluster"
#   availability_zones      = ["us-east-1a", "us-east-1b"]
#   backup_retention_period = 5
#   skip_final_snapshot     = true
#   master_username         = "OneEdgeDBUser"
#   master_password         = "OneEdgeDBPWS"
#   port                    = 27017
#   db_subnet_group_name    = "oe-db-subnet-group"
#   engine_version          = "4.0.0"
# }

# resource "aws_docdb_cluster_instance" "oe-db-instance" {
#   count              = 1
#   identifier         = "oe-db-instance-${count.index}"
#   cluster_identifier = aws_docdb_cluster.oe-db-cluster.id
#   instance_class     = "db.t3.medium"
#   engine_version     = "4.0.0"
# }



# # ####### ELB - ELASTIC LOAD BALANCE #######
resource "aws_security_group" "oe-ecs-elb-sg" {
  name        = "oe-ecs-elb-sg"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.oe-vpc.id

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
    Name = "oe-ecs-elb-sg"
  }
}

resource "aws_lb" "oe-ecs-elb" {
  name               = "oe-ecs-elb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.oe-ecs-elb-sg.id]
  subnets            = [aws_subnet.oe-subnet-01.id, aws_subnet.oe-subnet-02.id]

  enable_deletion_protection = false
  tags = {
    Name = "oe-ecs-elb"
  }
}

## ELB Target Group and ELB Listener, both of them will be by ECS Service
resource "aws_lb_target_group" "oe-ecs-elb-tg-auth" {
  name     = "oe-ecs-elb-tg-auth"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.oe-vpc.id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/v1/auth/ping"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

}

resource "aws_lb_target_group" "oe-ecs-elb-tg-billing" {
  name     = "oe-ecs-elb-tg-billing"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.oe-vpc.id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/v1/billing/ping"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

}

resource "aws_lb_target_group" "oe-ecs-elb-tg-tenants" {
  name     = "oe-ecs-elb-tg-tenants"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = aws_vpc.oe-vpc.id

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "2"
    interval            = "30"
    matcher             = "200"
    path                = "/v1/tenants/ping"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

}

resource "aws_lb_listener" "oe-ecs-elb-listener" {
  load_balancer_arn = aws_lb.oe-ecs-elb.arn
  port              = "80"
  protocol          = "HTTP"

  # default_action {
  #   target_group_arn = aws_lb_target_group.oe-ecs-elb-tg-auth.arn
  #   type             = "forward"
  # }
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "ELB default response action"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_rule" "oe-ecs-elb-lr-auth" {
  listener_arn = aws_lb_listener.oe-ecs-elb-listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oe-ecs-elb-tg-auth.arn
  }

  condition {
    path_pattern {
      values = ["/v1/auth/*"]
    }
  }
}

resource "aws_lb_listener_rule" "oe-ecs-elb-lr-billing" {
  listener_arn = aws_lb_listener.oe-ecs-elb-listener.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oe-ecs-elb-tg-billing.arn
  }

  condition {
    path_pattern {
      values = ["/v1/billing/*"]
    }
  }
}

resource "aws_lb_listener_rule" "oe-ecs-elb-lr-tenants" {
  listener_arn = aws_lb_listener.oe-ecs-elb-listener.arn
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.oe-ecs-elb-tg-tenants.arn
  }

  condition {
    path_pattern {
      values = ["/v1/tenants/*"]
    }
  }
}


###### ECS CLUSTER #######
resource "aws_security_group" "oe-ecs-cluster-sg" {
  name        = "oe-ecs-cluster-sg"
  description = "Allow ssh inbound traffic"
  vpc_id      = aws_vpc.oe-vpc.id

  ingress {
    description      = "Ssh from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description      = "for testing"
    from_port        = 3000
    to_port          = 65535
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    description     = "Http from ELB"
    from_port       = 3000
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.oe-ecs-elb-sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "oe-ecs-cluster-sg"
  }
}

resource "aws_iam_instance_profile" "oe-ecs-role-instance-profile" {
  name = "oe-ecs-role-instance-profile"
  role = aws_iam_role.oe-ecs-role.name
}

resource "aws_iam_role" "oe-ecs-role" {
  name = "oe-ecs-role"
  path = "/"

  assume_role_policy = jsonencode(
    {
      Version : "2012-10-17",
      Statement : [
        {
          Action : "sts:AssumeRole",
          Principal : {
            Service : "ec2.amazonaws.com"
          },
          Effect : "Allow",
          Sid : ""
        }
      ]
  })
}

resource "aws_iam_role_policy_attachment" "oe-ecs-role-policy-attachment" {
  role       = aws_iam_role.oe-ecs-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_launch_configuration" "oe-ecs-cluster-launch-config" {
  name                        = "oe-ecs-cluster-launch-config"
  image_id                    = "ami-005425225a11a4777"
  instance_type               = "t2.micro"
  key_name                    = "test-ec2"
  iam_instance_profile        = aws_iam_instance_profile.oe-ecs-role-instance-profile.arn
  associate_public_ip_address = "true"
  security_groups             = [aws_security_group.oe-ecs-cluster-sg.id]
  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.oe-ecs-cluster.name} >> /etc/ecs/ecs.config;echo ECS_BACKEND_HOST= >> /etc/ecs/ecs.config;"
  root_block_device {
    volume_type           = "gp2"
    volume_size           = 30
    delete_on_termination = true
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "oe-ecs-autoscaling-group" {
  name                      = "ecs-autoscaling-group"
  max_size                  = 2
  min_size                  = 0
  desired_capacity          = 1
  vpc_zone_identifier       = [aws_subnet.oe-subnet-01.id, aws_subnet.oe-subnet-02.id]
  launch_configuration      = aws_launch_configuration.oe-ecs-cluster-launch-config.name
  health_check_grace_period = 300
  health_check_type         = "EC2"
  tags = [{
    key                 = "Name"
    value               = "oe-ecs-cluster-launch-config"
    propagate_at_launch = true
  }]
}

resource "aws_ecs_cluster" "oe-ecs-cluster" {
  name = "oe-ecs-cluster"
  tags = {
    Name = "oe-ecs-cluster"
  }
}

### ECS TASKS AND SERVICES ###
resource "aws_ecs_task_definition" "oe-ecs-backend-auth" {
  family = "oe-ecs-backend-auth"
  container_definitions = jsonencode([
    {
      name : "oe-ecs-backend-auth-container",
      image : "105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-auth:latest",
      cpu : 128,
      memory : 128,
      essential : true,
      portMappings : [
        {
          containerPort : 3001,
          hostPort : 0
        }
      ],
      environment : [
        {
          name : "NODE_ENV",
          value : "development"
        }
      ],
    }
  ])
}

resource "aws_ecs_task_definition" "oe-ecs-backend-billing" {
  family = "oe-ecs-backend-billing"
  container_definitions = jsonencode([
    {
      name : "oe-ecs-backend-billing-container",
      image : "105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-billing:latest",
      cpu : 128,
      memory : 128,
      essential : true,
      portMappings : [
        {
          containerPort : 3001,
          hostPort : 0
        }
      ],
      environment : [
        {
          name : "NODE_ENV",
          value : "development"
        }
      ],
    }
  ])
}

resource "aws_ecs_task_definition" "oe-ecs-backend-tenants" {
  family = "oe-ecs-backend-tenants"
  container_definitions = jsonencode([
    {
      name : "oe-ecs-backend-tenants-container",
      image : "105019345634.dkr.ecr.us-east-1.amazonaws.com/oe-backend-tenants:latest",
      cpu : 128,
      memory : 128,
      essential : true,
      portMappings : [
        {
          containerPort : 3001,
          hostPort : 0
        }
      ],
      environment : [
        {
          name : "NODE_ENV",
          value : "development"
        }
      ],
    }
  ])
}

resource "aws_ecs_service" "oe-ecs-backend-auth-service" {
  name = "oe-ecs-backend-auth-service"
  ### iam_role        = "tester"
  launch_type     = "EC2"
  cluster         = aws_ecs_cluster.oe-ecs-cluster.id
  task_definition = aws_ecs_task_definition.oe-ecs-backend-auth.arn
  desired_count   = 2


  load_balancer {
    target_group_arn = aws_lb_target_group.oe-ecs-elb-tg-auth.arn
    container_port   = 3001
    container_name   = "oe-ecs-backend-auth-container"
  }
}

resource "aws_ecs_service" "oe-ecs-backend-billing-service" {
  name = "oe-ecs-backend-billing-service"
  ### iam_role        = "tester"
  launch_type     = "EC2"
  cluster         = aws_ecs_cluster.oe-ecs-cluster.id
  task_definition = aws_ecs_task_definition.oe-ecs-backend-billing.arn
  desired_count   = 2


  load_balancer {
    target_group_arn = aws_lb_target_group.oe-ecs-elb-tg-billing.arn
    container_port   = 3001
    container_name   = "oe-ecs-backend-billing-container"
  }
}

resource "aws_ecs_service" "oe-ecs-backend-tenants-service" {
  name = "oe-ecs-backend-tenants-service"
  ### iam_role        = "tester"
  launch_type     = "EC2"
  cluster         = aws_ecs_cluster.oe-ecs-cluster.id
  task_definition = aws_ecs_task_definition.oe-ecs-backend-tenants.arn
  desired_count   = 2


  load_balancer {
    target_group_arn = aws_lb_target_group.oe-ecs-elb-tg-tenants.arn
    container_port   = 3001
    container_name   = "oe-ecs-backend-tenants-container"
  }
}










####### Stage / Test Environment #######
####### EC2 MongoDB for Stage or Test #######

# resource "aws_security_group" "oe-ec2-mongodb-stage-sg" {
#   name        = "oe-ec2-mongodb-stage-sg"
#   description = "Allow ssh inbound traffic"
#   vpc_id      = aws_vpc.oe-vpc.id

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
#     Name = "oe-ec2-mongodb-stage-sg"
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

# resource "aws_instance" "oe-stage-mongodb" {
#   ami                         = data.aws_ami.amazon_linux_2.id
#   instance_type               = "t2.micro"
#   key_name                    = "test-ec2"
#   associate_public_ip_address = "true"
#   security_groups             = [aws_security_group.oe-ec2-mongodb-stage-sg.id]
#   subnet_id                   = aws_subnet.oe-subnet-01.id
#   user_data                   = "#!/bin/bash\nsudo yum update -y && sudo amazon-linux-extras install docker && sudo yum install docker && sudo service docker start && sudo usermod -a -G docker ec2-user && docker run -d --name 1edge-mongodb --restart=always -e MONGO_INITDB_ROOT_USERNAME=OneEdgeDBUser -e MONGO_INITDB_ROOT_PASSWORD=OneEdgeDBPWS -p 27017:27017 -d mongo"


#   tags = {
#     Name = "oe-stage-mongodb"
#   }
# }


# output "amazon_linux_2_id" {
#   value = data.aws_ami.amazon_linux_2.id
# }
# output "mongodb_stage_public_ip" {
#   value = aws_instance.oe-stage-mongodb.public_ip
# }

output "loadbalance_public_url" {
  value = aws_lb.oe-ecs-elb.dns_name
}

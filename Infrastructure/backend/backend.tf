
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

# resource "aws_ecr_repository" "one-edge-backend-fw-security" {
#   name                 = "one-edge-backend-fw-security"
#   image_tag_mutability = "MUTABLE"

#   image_scanning_configuration {
#     scan_on_push = true
#   }
# }

# resource "aws_ecr_repository" "one-edge-backend-billing" {
#   name                 = "one-edge-backend-billing"
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


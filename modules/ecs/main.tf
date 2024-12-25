###########################################################################
# main.tf                                                   		          #
###########################################################################
# Creates necessary AWS infrastructure for a Vitess ECS cluster           #
###########################################################################

###########################################################################
# VPC                                                                     #
###########################################################################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "vitess" {
  vpc_id = resource.aws_vpc.main.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_security_group" "vitess" {
  name = "vitess-security-group"
  description = "Allow inbound traffic Vitess services"
  vpc_id = resource.aws_vpc.main.id
}

resource "aws_security_group" "apprunner" {
  name = "apprunner-security-group"
  vpc_id = resource.aws_vpc.main.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "apprunner_to_vitess" {
  type = "ingress"
  from_port = 15999
  to_port = 15999
  protocol = "tcp"
  security_group_id = aws_security_group.vitess.id
  source_security_group_id = aws_security_group.apprunner.id
}

###########################################################################
# ECS IAM - included here instead of iam module for testability purposes  #
###########################################################################

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_execution.json
}

data "aws_iam_policy_document" "ecs_task_execution" {
  statement {
    principals {
      type = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

##########################################################################
# ECS                                                   							   #
##########################################################################

resource "aws_ecs_cluster" "vitess_cluster" {
  name = "vitess-cluster"
  
  configuration {
    execute_command_configuration {
      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name = aws_cloudwatch_log_group.vitess.name
      }
      logging = "OVERRIDE"
    }
  }
}

resource "aws_cloudwatch_log_group" "vitess" {
  name = "vitess"
}

resource "aws_ecs_task_definition" "vitess_task" {
  family = "vitess-task"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu = "1024"
  memory = "2048"
  execution_role_arn = resource.aws_iam_role.ecs_task_execution_role.arn
  container_definitions = data.local_file.vitess_container_definition.content 
}

data "local_file" "vitess_container_definition" {
  filename = "${path.module}/task-definitions/vitess_container_definition.json"
}

resource "aws_ecs_service" "vitess" {
  name = "vitess-service" 
  cluster = resource.aws_ecs_cluster.vitess_cluster.id
  task_definition = resource.aws_ecs_task_definition.vitess_task.arn
  launch_type = "FARGATE"
  wait_for_steady_state = true

  network_configuration {
      subnets = [resource.aws_subnet.vitess.id]
      security_groups = [resource.aws_security_group.vitess.id]
      assign_public_ip = false
  }
}

data "aws_ecs_task" "vitess_task" {
  cluster = aws_ecs_service.vitess_service.cluster_id
  task_id = aws_ecs_service.vitess_service.task_definition
}

resource "mysql_database" "databases" {
  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }
  name     = each.key

  depends_on = [aws_ecs_service.vitess]
}

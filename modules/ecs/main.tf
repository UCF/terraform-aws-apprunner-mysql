###########################################################################
# main.tf                                                   		          #
###########################################################################
# Creates necessary AWS infrastructure for a Vitess ECS cluster           #
###########################################################################

data "aws_caller_identity" "current" {}

###########################################################################
# VPC                                                                     #
###########################################################################

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.public.id
}

resource "aws_subnet" "vitess" {
  vpc_id = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "nat" {
  route_table_id = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id
}

resource "aws_route_table_association" "private" {
  subnet_id = aws_subnet.vitess.id
  route_table_id = aws_route_table.private.id
}

resource "aws_security_group" "vitess" {
  name = "vitess-security-group"
  description = "Allow inbound traffic Vitess services"
  vpc_id = aws_vpc.main.id

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "apprunner" {
  name = "apprunner-security-group"
  vpc_id = aws_vpc.main.id

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

resource "aws_eip" "nat" {
  vpc = true
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

resource "aws_iam_policy" "ecs_task_execution_policy" {
  name = "ecsTaskExecutionPolicy"
  description = "Policy for ECS task execution role to access ECR and CloudWatch logs"
  policy = data.aws_iam_policy_document.ecs_task_execution_permissions.json
}

data "aws_iam_policy_document" "ecs_task_execution_permissions" {
  # Allow CloudWatch log actions for ECS task logs
  statement {
    actions = [
      "logs:CreateLogStream", 
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
    ]
    resources = [
      "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/ecs/*"
    ]
  }

  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:BatchGetImage"
    ]
    resources = [
      "arn:aws:ecr:${var.region}:${data.aws_caller_identity.current.account_id}:repository/*"
    ]
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
  execution_role_arn = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = data.local_file.vitess_container_definition.content 
}

data "local_file" "vitess_container_definition" {
  filename = "${path.module}/task-definitions/vitess_container_definition.json"
}

resource "aws_ecs_service" "vitess" {
  name = "vitess-service" 
  cluster = aws_ecs_cluster.vitess_cluster.id
  task_definition = aws_ecs_task_definition.vitess_task.arn
  desired_count = 1
  launch_type = "FARGATE"
  wait_for_steady_state = true

  network_configuration {
      subnets = [aws_subnet.vitess.id]
      security_groups = [aws_security_group.vitess.id]
      assign_public_ip = false
  }
}

resource "aws_appautoscaling_target" "vitess" {
  max_capacity       = 10  
  min_capacity       = 1   
  resource_id        = "service/${aws_ecs_cluster.vitess_cluster.id}/${aws_ecs_service.vitess.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "scale_up" {
  name                    = "scale_up"
  resource_id        = "service/${aws_ecs_cluster.vitess_cluster.id}/${aws_ecs_service.vitess.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
  
  target_tracking_scaling_policy_configuration {
    target_value          = 70.0  # Target CPU utilization in percentage
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}


resource "null_resource" "ecs_task_network_interface" {
  provisioner "local-exec" {
    command = <<EOT
      # Poll ECS service until a task is running
      echo "Waiting for ECS service tasks to run..."

      while true; do
        # List tasks in the ECS service and fetch the task ARN
        TASK_ARN=$(aws ecs list-tasks --cluster ${aws_ecs_cluster.vitess_cluster.id} --service-name ${aws_ecs_service.vitess.name} --query "taskArns[0]" --output text)
    
        if [ "$TASK_ARN" != "None" ]; then
          echo "Task is running: $TASK_ARN"
          break
        else
          echo "No tasks running yet. Retrying in 5 seconds..."
          sleep 5
        fi
      done

      TASK_ARN=$(aws ecs list-tasks --cluster ${aws_ecs_cluster.vitess_cluster.id} --service-name ${aws_ecs_service.vitess.name} --query "taskArns[0]" --output text)
      
      # Use the task ARN to describe the task and get the network interface ID
      aws ecs describe-tasks --cluster ${aws_ecs_cluster.vitess_cluster.id} --tasks $TASK_ARN --query "tasks[0].attachments[0].details[?name=='networkInterfaceId'].value" --output text > task_network_interface_id.txt
    
      EOT
  }
  depends_on = [aws_ecs_service.vitess]
}

data "local_file" "ecs_task_network_interface" {
  depends_on = [null_resource.ecs_task_network_interface]
  filename   = "task_network_interface_id.txt"
}

data "aws_network_interface" "task_eni" {
  id = data.local_file.ecs_task_network_interface.content
}

resource "mysql_database" "databases" {
  for_each = { for idx, combo in var.app_env_list : "${combo.app}-${combo.env}" => combo }
  name     = each.key

  depends_on = [aws_ecs_service.vitess]
}



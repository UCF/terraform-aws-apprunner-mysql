###########################################################################
# main.tf                                                   		          #
###########################################################################
# Creates necessary AWS infrastructure for a Vitess ECS cluster           #
###########################################################################
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


####################################################################
# ECS                                             							   #
####################################################################

resource "aws_ecs_cluster" "vitess_cluster" {
  name = "vitess-cluster"
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

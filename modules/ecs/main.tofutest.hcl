variables {
  applications = ["announcements", "template"]
  environments = ["dev", "test"]
  app_env_list = [
    { app = "announcements", env = "dev" },
    { app = "announcements", env = "test" },
    { app = "template", env = "dev" },
    { app = "template", env = "test" },
  ]
  passwords    = ["anndev", "anntest", "tempdev", "temptest"]   
}

#####################################################################
# VPC Tests                                                         #
#####################################################################

run "private_subnets_are_created" {
  assert {
    condition = resource.aws_subnet.vitess.map_public_ip_on_launch == false 
    error_message = "Subnet not mapped to private IP on launch"
  }
}

run "security_group_in_vpc" {
  assert {
    condition = resource.aws_security_group.vitess.vpc_id == resource.aws_vpc.main.id
    error_message = "Security group not in VPC"
  }
}


#####################################################################
# ECS IAM Tests                                                     #
#####################################################################

run "ecs_iam_role_has_correct_name_and_policy" {
  assert {
    condition = resource.aws_iam_role.ecs_task_execution_role.name == "ecsTaskExecutionRole"
    error_message = "ECS IAM role does not have correct name"
  }

  assert {
    condition = jsondecode(resource.aws_iam_role.ecs_task_execution_role.assume_role_policy) == jsondecode(data.aws_iam_policy_document.ecs_task_execution.json)
    error_message = "ECS IAM policy does not have correct data."
  }

  assert {
    condition = contains(data.aws_iam_policy_document.ecs_task_execution.statement[0].actions, "sts:AssumeRole")
    error_message = "ECS IAM Policy Document does not have correct actions."
  }

  assert {
    condition     = contains([for principal in data.aws_iam_policy_document.ecs_task_execution.statement[0].principals : principal.type], "Service")
    error_message = "Apprunner Role Principal Type is not Service"
  }

  assert {
    condition     = contains(flatten([for principal in data.aws_iam_policy_document.ecs_task_execution.statement[0].principals : principal.identifiers]), "ecs-tasks.amazonaws.com")
    error_message = "Apprunner Role Principal identifier is not build.apprunner.amazonaws.com"
  }

}

###################################################################
# ECS                                                             #
###################################################################

run "ecs_cluster_is_set_up" {
  assert {
    condition     = resource.aws_ecs_cluster.vitess_cluster.name == "vitess-cluster"
    error_message = "AWS ECS Cluster named `vitess_cluster` not found."
  }

  assert { 
    condition = resource.aws_ecs_cluster.vitess_cluster.configuration[0].execute_command_configuration[0].log_configuration[0].cloud_watch_encryption_enabled == true
    error_message = "ECS Cluster CloudWatch Encryption not enabled"
  }

  assert { 
    condition = resource.aws_ecs_cluster.vitess_cluster.configuration[0].execute_command_configuration[0].log_configuration[0].cloud_watch_log_group_name == resource.aws_cloudwatch_log_group.vitess.name
    error_message = "CloudWatch Log Group not connected to ECS Cluster"
  }

}

run "aws_ecs_vitess_task_definition_is_set_up" {
  assert {
    condition = resource.aws_ecs_task_definition.vitess_task.family == "vitess-task"
    error_message = "Vitess task family incorrectly named or task definition not properly applied."
  }

  assert {
    condition = contains(resource.aws_ecs_task_definition.vitess_task.requires_compatibilities, "FARGATE")
    error_message = "Vitess task not configured for ECS Fargate."
  }

  assert { 
    condition = resource.aws_ecs_task_definition.vitess_task.network_mode == "awsvpc"
    error_message = "Vitess task not configured for awsvpc network mode."
  }

  assert {
    condition = resource.aws_ecs_task_definition.vitess_task.cpu != ""
    error_message = "Vitess task CPU must be set. Recommended `1024` (1 vCPU for moderate workloads)."
  }
  
  assert {
    condition = resource.aws_ecs_task_definition.vitess_task.memory != ""
    error_message = "Vitess task Memory must be set. Recommended `2048` (2 GB of memory)."
  }

  assert {
    condition = resource.aws_ecs_task_definition.vitess_task.container_definitions != ""
    error_message = "Vitess task container definitions must be set, preferably with container_definitions data source."
  }
}

run "aws_ecs_vitess_service_is_set_up" {
  assert {
    condition = resource.aws_ecs_service.vitess.name == "vitess-service"
    error_message = "Vitess Service incorrectly named or service not created."
  }

  assert {
    condition = resource.aws_ecs_service.vitess.cluster == resource.aws_ecs_cluster.vitess_cluster.id
    error_message = "Vitess Cluster incorrectly connected."
  }

  assert {
    condition = resource.aws_ecs_service.vitess.task_definition == aws_ecs_task_definition.vitess_task.arn
    error_message = "Vitess Task Definition incorrectly connected."
  }

  assert {
    condition = resource.aws_ecs_service.vitess.launch_type == "FARGATE"
    error_message = "Vitess Launch Type not FARGATE."
  }
  
  assert { 
    condition = resource.aws_ecs_service.vitess.wait_for_steady_state == true
    error_message = "Vitess Service will not wait for steady state before continuing."
  }
}

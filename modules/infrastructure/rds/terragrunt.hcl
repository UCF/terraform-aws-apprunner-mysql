terraform {
  source = "." 
}

include {
  path = find_in_parent_folders()
}

dependency "appenvlist" {
  config_path = "../appenvlist"
  mock_outputs_allowed_terraform_commands = ["init", "plan", "destroy"]
  mock_outputs = {
    app_env_list = [
      { app = "announcements", env = "dev" },
      { app = "announcements", env = "test" },
      { app = "template", env = "dev" },
      { app = "template", env = "test" },
    ]
  }
}

dependency "vpc" {
  config_path = "../vpc"
  mock_outputs_allowed_terraform_commands = ["init", "plan", "destroy"]
  mock_outputs = {
    rds_secgrp_id = "123"
    db_sg_name = "db_sg"
    bastion_sg_id = "123"
    subnet_id = "123"
  }
}

inputs = {
  app_env_list = dependency.appenvlist.outputs.app_env_list
  rds_secgrp_id = dependency.vpc.outputs.rds_secgrp_id 
  db_sg_name = dependency.vpc.outputs.db_sg_name
  bastion_sg_id = dependency.vpc.outputs.bastion_sg_id
  subnet_id = dependency.vpc.outputs.subnet_id
}

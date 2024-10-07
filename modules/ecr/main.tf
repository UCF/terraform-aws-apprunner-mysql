module "appenvlist" {
	source = "../appenvlist"
}

resource "aws_ecr_repository" "app_repos" {
	for_each = {for combo in module.appenvlist.app_env_list : "${combo.app}-${combo.env}" => combo }

	name = "${each.value.app}-${each.value.env}"
	force_delete = true
}

variables {
	applications = ["announcements", "template"]
	environments = ["dev", "test"]
}


run "test" {
	assert {
		condition = output.app_env_list == [
			{app = "announcements", env = "dev"},
      			{app = "announcements", env = "test"},
			{app = "template", env = "dev"},
			{app = "template", env = "test"},
    		]

		error_message = "Incorrect app-env list."
	}
}


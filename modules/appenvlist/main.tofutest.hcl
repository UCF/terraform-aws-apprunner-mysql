run "test2by2" {
  variables {
    applications = ["announcements", "template"]
    environments = ["dev", "test"]
  }

  assert {
    condition = output.app_env_list == [
      { app = "announcements", env = "dev" },
      { app = "announcements", env = "test" },
      { app = "template", env = "dev" },
      { app = "template", env = "test" },
    ]

    error_message = "Incorrect app-env list."
  }
}

run "test5by3" {
  variables {
    applications = ["announcements", "template", "knightsherald", "events", "marquee"]
    environments = ["dev", "test", "prod"]
  }

  assert {
    condition = output.app_env_list == [
      { app = "announcements", env = "dev" },
      { app = "announcements", env = "test" },
      { app = "announcements", env = "prod" },
      { app = "template", env = "dev" },
      { app = "template", env = "test" },
      { app = "template", env = "prod" },
      { app = "knightsherald", env = "dev" },
      { app = "knightsherald", env = "test" },
      { app = "knightsherald", env = "prod" },
      { app = "events", env = "dev" },
      { app = "events", env = "test" },
      { app = "events", env = "prod" },
      { app = "marquee", env = "dev" },
      { app = "marquee", env = "test" },
      { app = "marquee", env = "prod" },
    ]

    error_message = "Incorrect app-env list."
  }
}


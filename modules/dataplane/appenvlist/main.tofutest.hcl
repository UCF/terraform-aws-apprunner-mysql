#######################################################################
# main.tofutest.hcl                                                   #
#######################################################################
# This file contains the tofu tests for this module. These tests can  #
# be run by typing `tofu test` in the terminal. To learn more about   #
# tofu testing, see: https://opentofu.org/docs/cli/commands/test/     #
#######################################################################


run "test2by2" {
  # Test if the app_env_list properly outputs the 2x2 object list

  # Arrange
  variables {
    applications = ["announcements", "template"]
    environments = ["dev", "test"]
  }

  # Act
  ## (Occurs when applying the infrastructure)

  # Assert
  assert {
    condition = output.app_env_list == [
      { app = "announcements", env = "dev" },
      { app = "announcements", env = "test" },
      { app = "template", env = "dev" },
      { app = "template", env = "test" },
    ]

    error_message = "Incorrect app_env_list output. Ensure the app_env_list properly flattens the app_env_combinations in locals.tf"
  }
}

run "test5by3" {
  # Test if the app_env_list properly outputs the 5x3 object list

  # Arrange
  variables {
    applications = ["announcements", "template", "knightsherald", "events", "marquee"]
    environments = ["dev", "test", "prod"]
  }

  # Act
  ## (Occurs when applying the infrastructure)

  # Assert
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

    error_message = "Incorrect app_env_list output. Ensure the app_env_list properly flattens the app_env_combinations in locals.tf"
  }
}


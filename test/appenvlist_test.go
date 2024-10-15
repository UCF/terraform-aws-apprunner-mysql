package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAppEnvListFlattening(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/appenvlist",

		Vars: map[string]interface{}{
			"applications": []string{
				"announcements", "template",
			},
			"environments": []string{
				"dev", "test",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	actualAppEnvList := terraform.OutputList(t, terraformOptions, "app_env_list")

	expectedAppEnvList := []string{
		"map[app:announcements env:dev]",
		"map[app:announcements env:test]",
		"map[app:template env:dev]",
		"map[app:template env:test]",
	}

	assert.Equal(t, expectedAppEnvList, actualAppEnvList, "The flattened list is incorrect.")

}

func TestLargerAppEnvListFlattening(t *testing.T) {

	terraformOptions := &terraform.Options{
		TerraformDir: "../modules/appenvlist",

		Vars: map[string]interface{}{
			"applications": []string{
				"announcements", "template", "events", "herald",
			},
			"environments": []string{
				"dev", "test", "prod",
			},
		},
	}

	defer terraform.Destroy(t, terraformOptions)
	terraform.InitAndApply(t, terraformOptions)

	actualAppEnvList := terraform.OutputList(t, terraformOptions, "app_env_list")

	expectedAppEnvList := []string{
		"map[app:announcements env:dev]",
		"map[app:announcements env:test]",
		"map[app:announcements env:prod]",
		"map[app:template env:dev]",
		"map[app:template env:test]",
		"map[app:template env:prod]",
		"map[app:events env:dev]",
		"map[app:events env:test]",
		"map[app:events env:prod]",
		"map[app:herald env:dev]",
		"map[app:herald env:test]",
		"map[app:herald env:prod]",
	}

	assert.Equal(t, expectedAppEnvList, actualAppEnvList, "The flattened list is incorrect.")

}

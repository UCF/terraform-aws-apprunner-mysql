package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAppEnvListFlattening(t *testing.T) {
	t.Parallel()

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

	expectedAppEnvList := []string(
		[]string{
		"map[app:announcements env:dev]",
		"map[app:announcements env:test]",
		"map[app:template env:dev]",
		"map[app:template env:test]",
		},
	)

	assert.Equal(t, expectedAppEnvList, actualAppEnvList, "The flattened list is incorrect.")

} 

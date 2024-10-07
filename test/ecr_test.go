package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestECRCreation(t *testing.T) {
	t.Parallel()

	appEnvOptions := &terraform.Options{
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

	defer terraform.Destroy(t, appEnvOptions)
	terraform.InitAndApply(t, appEnvOptions)

	ecrOptions := &terraform.Options{
		TerraformDir: "../modules/ecr",
	}

	defer terraform.Destroy(t, ecrOptions)
	terraform.InitAndApply(t, ecrOptions)

	actualRepoNames := terraform.OutputList(t, ecrOptions, "ecr_repo_names")

	expectedRepoNames := []string{
		"announcements-dev",
		"announcements-test",
		"template-dev",
		"template-test",
	}

	assert.Equal(t, expectedRepoNames, actualRepoNames, "The ECR repository names are incorrect.")

}

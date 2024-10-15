package test

import (
	"testing"
	"path/filepath"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)

func TestECRCreation(t *testing.T) {
	t.Parallel()

	tempTestFolder := filepath.Join(".", "/stages")

	defer test_structure.RunTestStage(t, "teardown_ecr_module", func() {

		ecrOptions := test_structure.LoadTerraformOptions(t, tempTestFolder)
		terraform.Destroy(t, ecrOptions)
	})

	test_structure.RunTestStage(t, "deploy_ecr_module", func() {

		ecrOptions := &terraform.Options{
			TerraformDir: "../modules/ecr",
			Vars: map[string]interface{}{
				"applications": []string{
																				"announcements", "template",
																},
																"environments": []string{
																				"dev", "test",
																},
			},
		}

	test_structure.SaveTerraformOptions(t, tempTestFolder, ecrOptions)

	terraform.InitAndApply(t, ecrOptions)

	actualRepoNames := terraform.OutputList(t, ecrOptions, "ecr_repo_names")

	expectedRepoNames := []string{
		"announcements-dev",
		"announcements-test",
		"template-dev",
		"template-test",
	}

	assert.Equal(t, expectedRepoNames, actualRepoNames, "The ECR repository names are incorrect.")
	})
}

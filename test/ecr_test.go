package test

import (
	"testing"
	"path/filepath"

	"github.com/gruntwork-io/terratest/modules/terraform"
	test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
	"github.com/stretchr/testify/assert"
)


func TestECRCreation(t *testing.T) {

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

func TestiLargerECRCreation(t *testing.T) {

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
						"announcements", "template", "herald", "events",
				},
				"environments": []string{
						"dev", "test", "prod",
				},
			},
		}

	test_structure.SaveTerraformOptions(t, tempTestFolder, ecrOptions)

	terraform.InitAndApply(t, ecrOptions)

	actualRepoNames := terraform.OutputList(t, ecrOptions, "ecr_repo_names")

	expectedRepoNames := []string{
		"announcements-dev",
		"announcements-test",
		"announcements-prod",
		"template-dev",
		"template-test",
		"template-prod",
		"herald-dev",
		"herald-test",
		"herald-prod",
		"events-dev",
		"events-test",
		"events-prod",
	}

	assert.Equal(t, expectedRepoNames, actualRepoNames, "The ECR repository names are incorrect.")
	})
}

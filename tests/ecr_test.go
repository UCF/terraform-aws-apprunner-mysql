package tests

import (
	"testing"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestECRRepositories(t *testing.T) {
	terraformOptions := &terraform.Options{
	    TerraformDir: "../infrastructure"
	}
	
	// Ensure the code is cleaned up at the end of the test
	defer terraform.Destroy(t, terraformOptions)
	
	// Run Terraform Init and Apply
	terraform.InitAndApply(t, terraformOptions)

	repoUrl := terraform.Output(t, terraformOptions, "repository_url")
	assert.Contains(t, repoUrl, "amazonaws.com")
}

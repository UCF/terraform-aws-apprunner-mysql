Feature: Create AWS ECR Repositories for each application and environment

Scenario: Create ECR Repositories
    Given I have the necessary IAM permissions
    When I apply the OpenTofu configuration
    Then ECR repositories should be created
    And the repositories' URLs should be output

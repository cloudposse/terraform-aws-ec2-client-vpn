package test

import (
  "github.com/gruntwork-io/terratest/modules/random"
  "github.com/gruntwork-io/terratest/modules/terraform"
  test_structure "github.com/gruntwork-io/terratest/modules/test-structure"
  "github.com/stretchr/testify/assert"
  "os"
  "strings"
  "testing"
)

func cleanup(t *testing.T, terraformOptions *terraform.Options, tempTestFolder string) {
  terraform.Destroy(t, terraformOptions)
  os.RemoveAll(tempTestFolder)
}

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
  t.Parallel()
  randId := strings.ToLower(random.UniqueId())
  attributes := []string{randId}

  rootFolder := "../../"
  terraformFolderRelativeToRoot := "examples/complete"
  varFiles := []string{"fixtures.us-east-2.tfvars"}

  tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

  terraformOptions := &terraform.Options{
    // The path to where our Terraform code is located
    TerraformDir: tempTestFolder,
    Upgrade:      true,
    // Variables to pass to our Terraform code using -var-file options
    VarFiles: varFiles,
    Vars: map[string]interface{}{
      "attributes": attributes,
    },
  }

  // At the end of the test, run `terraform destroy` to clean up any resources that were created
  defer cleanup(t, terraformOptions, tempTestFolder)

  // This will run `terraform init` and `terraform apply` and fail the test if there are any errors
  terraform.InitAndApply(t, terraformOptions)

  // Run `terraform output` to get the value of an output variable
  vpnEndpointArn := terraform.Output(t, terraformOptions, "vpn_endpoint_arn")
  vpnEndpointId := terraform.Output(t, terraformOptions, "vpn_endpoint_id")
  vpnEndpointDnsName := terraform.Output(t, terraformOptions, "vpn_endpoint_dns_name")
  clientConfiguration := terraform.Output(t, terraformOptions, "client_configuration")

  assert.NotNil(t, vpnEndpointArn)
  assert.NotNil(t, vpnEndpointId)
  assert.NotNil(t, vpnEndpointDnsName)
  assert.NotNil(t, clientConfiguration)
}

func TestExamplesCompleteDisabled(t *testing.T) {
  t.Parallel()
  randId := strings.ToLower(random.UniqueId())
  attributes := []string{randId}

  rootFolder := "../../"
  terraformFolderRelativeToRoot := "examples/complete"
  varFiles := []string{"fixtures.us-east-2.tfvars"}

  tempTestFolder := test_structure.CopyTerraformFolderToTemp(t, rootFolder, terraformFolderRelativeToRoot)

  terraformOptions := &terraform.Options{
    // The path to where our Terraform code is located
    TerraformDir: tempTestFolder,
    Upgrade:      true,
    // Variables to pass to our Terraform code using -var-file options
    VarFiles: varFiles,
    Vars: map[string]interface{}{
      "attributes": attributes,
      "enabled":    "false",
    },
  }

  // At the end of the test, run `terraform destroy` to clean up any resources that were created
  defer cleanup(t, terraformOptions, tempTestFolder)

  // This will run `terraform init` and `terraform apply` and fail the test if there are any errors
  terraform.InitAndApply(t, terraformOptions)

  // Get all the output and lookup a field. Pass if the field is missing or empty.
  example := terraform.OutputAll(t, terraformOptions)["vpn_endpoint_id"]

  // Verify we're getting back the outputs we expect
  assert.Empty(t, example, "When disabled, module should have no outputs.")
}

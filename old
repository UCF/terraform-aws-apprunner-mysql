package main

import (
	"archive/zip"
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"github.com/aws/aws-sdk-go/service/ssm"
)

const bucketName = "cm-staging-tfstate"

func main() {
	// Apply Terragrunt in the infrastructure module
	infrastructurePath := "modules/infrastructure"
	if err := ApplyTerragrunt(infrastructurePath); err != nil {
		log.Fatalf("Error applying infrastructure: %v\n", err)
	}
	fmt.Println("Infrastructure applied successfully.")

	// Load bastion info
	bastionInfo, err := LoadBastionInfo()
	if err != nil {
		log.Fatalf("Error loading bastion info: %v\n", err)
	}

	if err := InstallTools(bastionInfo.BastionId.Value); err != nil {
		log.Fatalf("Error installing tools: %v\n", err)
	}
	// Append RDS endpoint to dev.tfvars
	dataplanePath := "../../../modules/dataplane"
	if err := appendRDSEndpointToTFVars(dataplanePath, bastionInfo.RDSEndpoint.Value); err != nil {
		log.Fatalf("Error appending RDS endpoint to dev.tfvars: %v\n", err)
	}

	if err := copyAndSendToS3(dataplanePath); err != nil {
		log.Fatalf("Error sending dataplane to EC2: %v\n", err)
	}

	if err := copyToEC2(bastionInfo.BastionId.Value); err != nil {
		log.Fatalf("Error copying dataplane to EC2: %v\n", err)
	}

	// Execute commands on the bastion instance
	command := fmt.Sprintf("cd /home/ssm-user/dataplane && sudo terragrunt run-all init && yes \"y\" | sudo terragrunt run-all apply --terragrunt-non-interactive -var-file=/home/ssm-user/dataplane/dev.tfvars")
	if err := ExecuteSSMCommand(bastionInfo.BastionId.Value, command); err != nil {
		log.Fatalf("Error executing SSM command %v\n", err)
	}

	fmt.Println("Data plane applied successfully.")
}

// BastionInfo holds the host information
type BastionInfo struct {
	BastionId   BastionOutput `json:"bastion_instance_id"`
	RDSEndpoint BastionOutput `json:"rds_endpoint"`
}

type BastionOutput struct {
	Value string `json:"value"`
}

// LoadBastionInfo retrieves terragrunt output
func LoadBastionInfo() (BastionInfo, error) {
	var bastionInfo BastionInfo

	// Run terragrunt output command
	os.Chdir("rds")
	cmd := exec.Command("terragrunt", "output", "-json")
	var out bytes.Buffer
	cmd.Stdout = &out
	if err := cmd.Run(); err != nil {
		return bastionInfo, fmt.Errorf("terragrunt output command failed: %v", err)
	}

	// Parse JSON output
	var parsedOutput map[string]interface{}
	if err := json.Unmarshal([]byte(out.Bytes()), &parsedOutput); err != nil {
		return bastionInfo, fmt.Errorf("failed to unmarshal JSON: %v, output: %s", err, out.String())
	}

	fmt.Printf("Raw output: %s\n", out.String())
	// Extract bastion info from parsed JSON objects
	if bastionID, exists := parsedOutput["bastion_instance_id"]; exists {
		bastionIDMap, ok := bastionID.(map[string]interface{})
		if !ok {
			return bastionInfo, fmt.Errorf("unexpected format for bastion_instance_id")
		}
		bastionInfo.BastionId.Value = bastionIDMap["value"].(string)

		if rdsEndpoint, exists := parsedOutput["rds_endpoint"]; exists {
			rdsEndpointMap, ok := rdsEndpoint.(map[string]interface{})
			if !ok {
				return bastionInfo, fmt.Errorf("unexpected format for rds_endpoint")
			}
			bastionInfo.RDSEndpoint.Value = rdsEndpointMap["value"].(string)
		}
	}

	return bastionInfo, nil
}

func appendRDSEndpointToTFVars(dataplanePath, rdsEndpoint string) error {
	tfVarsFilePath := filepath.Join(dataplanePath, "dev.tfvars")

	file, err := os.OpenFile(tfVarsFilePath, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	if err != nil {
		return err
	}
	defer file.Close()

	line := fmt.Sprintf("rds_endpoint = \"%s\"\n", rdsEndpoint)

	if _, err := file.WriteString(line); err != nil {
		return err
	}

	return nil
}

func copyAndSendToS3(dataplanePath string) error {
	zipContent, err := zipDirectory(dataplanePath)
	if err != nil {
		return fmt.Errorf("error zipping directory: %v", err)
	}

	s3Session, err := session.NewSession(&aws.Config{Region: aws.String("us-east-1")})

	if err != nil {
		return fmt.Errorf("unable to create AWS session: %v", err)
	}

	s3Client := s3.New(s3Session)
	zipFileName := "dataplane.zip"

	_, err = s3Client.PutObject(&s3.PutObjectInput{
		Bucket: aws.String(bucketName),
		Key:    aws.String(zipFileName),
		Body:   bytes.NewReader(zipContent),
	})

	if err != nil {
		return fmt.Errorf("unable to upload zip file to S3: %v", err)
	}

	fmt.Println("File uploaded to S3 successfully.")

	return nil
}

func zipDirectory(src string) ([]byte, error) {
	buf := new(bytes.Buffer)
	zipWriter := zip.NewWriter(buf)

	err := filepath.Walk(src, func(file string, fi os.FileInfo, err error) error {
		if err != nil {
			return err
		}

		if file == src {
			return nil
		}

		relPath := strings.TrimPrefix(file, src+string(os.PathSeparator))

		if fi.IsDir() {
			_, err := zipWriter.Create(relPath + "/")
			return err
		}

		fileInZip, err := zipWriter.Create(relPath)
		if err != nil {
			return err
		}

		sourceFile, err := os.Open(file)
		if err != nil {
			return err
		}
		defer sourceFile.Close()

		_, err = copyFileToZip(sourceFile, fileInZip)
		return err
	})

	if err != nil {
		return nil, err
	}
	err = zipWriter.Close()
	if err != nil {
		return nil, err
	}

	return buf.Bytes(), nil
}

func copyFileToZip(sourceFile *os.File, fileInZip io.Writer) (int64, error) {
	n, err := io.Copy(fileInZip, sourceFile)
	return n, err
}

func copyToEC2(instanceID string) error {
	s3Url := fmt.Sprintf("s3://%s/%s", bucketName, "dataplane.zip")

	downloadCommand := fmt.Sprintf("aws s3 cp %s /home/ssm-user/dataplane.zip", s3Url)
	if err := ExecuteSSMCommand(instanceID, downloadCommand); err != nil {
		return fmt.Errorf("error downloading dataplane form S3: %v", err)
	}

	unzipCommand := "unzip -o /home/ssm-user/dataplane.zip -d /home/ssm-user/dataplane"
	if err := ExecuteSSMCommand(instanceID, unzipCommand); err != nil {
		return fmt.Errorf("error unzipping file on EC2: %v", err)
	}

	return nil
}

func CheckSSMAgent(instanceID string) error {
	checkCommand := "systemctl status amazon-ssm-agent"
	if err := ExecuteSSMCommand(instanceID, checkCommand); err != nil {
		fmt.Println("SSM agent is not installed. Installing...")
		return InstallSSMAgent(instanceID)
	}
	return nil
}

func InstallSSMAgent(instanceID string) error {
	installCommand := `
		if ! command -v amazon-ssm-agent &> /dev/null; then
			echo "Installing SSM agent..."
			sudo snap install amazon-ssm-agent --classic
			sudo snap start amazon-ssm-agent
		fi
	`
	return ExecuteSSMCommand(instanceID, installCommand)
}

func ExecuteSSMCommand(instanceID string, command string) error {
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("us-east-1"),
	})
	if err != nil {
		return fmt.Errorf("unable to create AWS session: %v", err)
	}

	svc := ssm.New(sess)

	input := &ssm.SendCommandInput{
		InstanceIds:  []*string{aws.String(instanceID)},
		DocumentName: aws.String("AWS-RunShellScript"),
		Parameters: map[string][]*string{
			"commands": {aws.String(command)},
		},
	}

	fmt.Printf("Executing command: %s\n", command)

	output, err := svc.SendCommand(input)
	if err != nil {
		return fmt.Errorf("failed to send command: %v", err)
	}

	commandId := *output.Command.CommandId
	fmt.Printf("Command ID: %s\n", commandId)

	err = waitForCommandCompletion(svc, commandId, instanceID)
	if err != nil {
		return fmt.Errorf("error while waiting for command completion: %v", err)
	}

	return nil
}

func waitForCommandCompletion(svc *ssm.SSM, commandId, instanceID string) error {
	time.Sleep(5 * time.Second)
	for {
		input := &ssm.GetCommandInvocationInput{
			CommandId:  aws.String(commandId),
			InstanceId: aws.String(instanceID),
		}

		resp, err := svc.GetCommandInvocation(input)
		if err != nil {
			return fmt.Errorf("failed to get command invocation status: %v", err)
		}

		if *resp.Status == "Success" {
			fmt.Println("Command executed successfully.")
			fmt.Printf("Command Output: %s\n", *resp.StandardOutputContent)
			return nil
		} else if *resp.Status == "Failed" || *resp.Status == "TimedOut" || *resp.Status == "Cancelling" {
			return fmt.Errorf("command failed with status: %s\nError: %s", *resp.Status, *resp.StandardErrorContent)
		}

		fmt.Println("Waiting for command to complete...")
		time.Sleep(5 * time.Second)
	}
}

func InstallTools(instanceID string) error {
	installCommands := `
	if ! command -v terragrunt &> /dev/null; then
		echo "Terragrunt not found. Installing..."
		sudo curl -Lo terragrunt  https://github.com/gruntwork-io/terragrunt/releases/download/v0.71.1/terragrunt_linux_amd64
		sudo chmod +x terragrunt
		sudo mv terragrunt /usr/local/bin
	fi

	if ! command -v tofu &> /dev/null; then
		echo "OpenTofu not found. Installing..."
		# Download the installer script:
		sudo curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh

		# Give it execution permissions:
		sudo chmod +x install-opentofu.sh

		# Run the installer:
		sudo ./install-opentofu.sh --install-method deb

		# Remove the installer:
		sudo rm -f install-opentofu.sh
	fi

	if ! command -v mysql &> /dev/null; then
		sudo apt-get install mysql-client
	fi

	if ! command -v unzip &> /dev/null; then
		sudo apt-get install unzip
	fi

	if command -v aws &> /dev/null; then
		echo "AWS CLI is installed."
	else
		curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
		unzip -o awscliv2.zip
		sudo ./aws/install	
	fi
	`
	return ExecuteSSMCommand(instanceID, installCommands)
}

func ApplyTerragrunt(dir string) error {
	if err := os.Chdir(dir); err != nil {
		return err
	}

	initCmd := exec.Command("terragrunt", "run-all", "init")
	var initOut bytes.Buffer
	initCmd.Stdout = &initOut
	initCmd.Stderr = &initOut
	if err := initCmd.Run(); err != nil {
		return fmt.Errorf("init command failed: %v, output: %s", err, initOut.String())
	}

	applyCmd := exec.Command("terragrunt", "run-all", "apply", "--terragrunt-non-interactive", "-var-file="+getAbsolutePath()+"/dev.tfvars")
	var applyOut bytes.Buffer
	applyCmd.Stdout = &applyOut
	applyCmd.Stderr = &applyOut
	if err := applyCmd.Run(); err != nil {
		return fmt.Errorf("apply command failed: %v, output: %s", err, applyOut.String())
	}

	return nil
}

func getAbsolutePath() string {
	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("Error getting current working directory: %v", err)
	}

	return wd
}

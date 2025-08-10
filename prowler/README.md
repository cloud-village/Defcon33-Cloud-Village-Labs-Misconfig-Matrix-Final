# Prowler Multi-Cloud CSPM Scanner for AWS & GCP

This repository provides a streamlined approach to assessing your cloud security posture across both Amazon Web Services (AWS) and Google Cloud Platform (GCP). It uses a simple script to execute the powerful [Prowler](https://github.com/prowler-cloud/prowler) security scanner, helping you evaluate your multi-cloud environments from a single command.

---

## Project Structure

The repository is organized for clarity and ease of use.

├── test.sh    # The main execution script

├── prowler_results/          # Auto-generated directory for scan reports

└── README.md                 # This documentation file


---

## Credential Setup

Proper authentication is required for Prowler to access and assess your cloud environments. Please configure credentials for each provider as detailed below.

### AWS (Default Profile)

The script leverages the standard AWS Command Line Interface (CLI) configuration. Prowler will use the credentials stored in your **default** profile.

1.  **Install the AWS CLI** if you do not have it.

2.  **Configure your default profile** by running the following command and providing your credentials when prompted:
    ```bash
    aws configure
    ```
    You will need to enter your **AWS Access Key ID**, **AWS Secret Access Key**, and a **Default region** (e.g., `us-east-1`). This command stores your credentials in the `~/.aws/` directory.

3.  **(Optional) Verify your configuration** by checking the current authenticated identity:
    ```bash
    aws sts get-caller-identity
    ```

---

## Running the Script

Once authentication is configured, you can run the scanner.

First, make the script executable:
```
chmod +x test.sh
```
Then, execute the script to begin the scan:
```
bash test.sh
```

The script will sequentially scan your default AWS account and the GCP project associated with your gcp.json file. All findings will be saved in timestamped subdirectories within the prowler_results/ folder.

Requirements
Before running the script, ensure the following tools are installed and accessible in your system's $PATH:

Prowler

AWS CLI (aws)

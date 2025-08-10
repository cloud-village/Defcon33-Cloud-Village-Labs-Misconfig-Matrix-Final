# Cloud Custodian Automation Script

This directory contains an automated script for running Cloud Custodian across multiple cloud providers (AWS, Azure, and GCP) to detect security misconfigurations and compliance violations.

## 📋 Prerequisites

### System Requirements
- **Operating System**: Linux, macOS, or Windows (with WSL)
- **Python**: Version 3.8 or higher
- **Shell**: Bash shell (for Linux/macOS) or PowerShell (for Windows)

### Required Software

#### 1. Python 3.8+
```bash
# Check Python version
python3 --version

# Install Python 3.8+ if not available
# Ubuntu/Debian:
sudo apt update && sudo apt install python3 python3-pip python3-venv

# macOS:
brew install python3

# Windows:
# Download from https://www.python.org/downloads/
```

#### 2. Cloud Provider CLI Tools

##### AWS CLI
```bash
# Ubuntu/Debian
sudo apt install awscli

# macOS
brew install awscli

# Windows
# Download from https://aws.amazon.com/cli/

# Configure AWS credentials
aws configure
```

##### Azure CLI
```bash
# Ubuntu/Debian
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# macOS
brew install azure-cli

# Windows
# Download from https://docs.microsoft.com/en-us/cli/azure/install-azure-cli

# Login to Azure
az login
```

##### GCP CLI (Optional - for GCP support)
```bash
# Ubuntu/Debian
curl https://sdk.cloud.google.com | bash
exec -l $SHELL

# macOS
brew install google-cloud-sdk

# Windows
# Download from https://cloud.google.com/sdk/docs/install

# Initialize and authenticate
gcloud init
gcloud auth login
```

## 📦 Required Libraries

The script automatically installs the following Python packages in a virtual environment:

- **c7n**: Core Cloud Custodian package with AWS support
- **c7n_azure**: Azure Cloud Custodian provider
- **c7n_gcp**: GCP Cloud Custodian provider

## 🔐 Credential Requirements

### AWS Credentials
- **Method**: AWS CLI configuration
- **Required**: Access Key ID, Secret Access Key, Default Region
- **Setup**: `aws configure`
- **Verification**: `aws sts get-caller-identity`

### Azure Credentials
- **Method**: Azure CLI authentication
- **Required**: Azure subscription access
- **Setup**: `az login`
- **Verification**: `az account show`

### GCP Credentials
- **Method**: Service Account JSON key file
- **Required**: 
  - Service account key file (`../gcp.json`)
  - GCP Project ID (if available)
- **Setup**: Place service account JSON file in parent directory
- **Verification**: File existence check

## 🚀 Installation & Setup

### 1. Clone or Download
```bash
# Navigate to the cloudcustodian directory
cd cloudcustodian
```

### 2. Make Script Executable
```bash
chmod +x test.sh
```

### 3. Run the Script
```bash
./test.sh
```

The script will automatically:
- Check Python version compatibility
- Create a Python virtual environment
- Install all required Cloud Custodian packages
- Verify package installation
- Present an interactive menu

## 📁 File Structure

```
cloudcustodian/
├── README.md                 # This file
├── test.sh                   # Main automation script
├── aws_policy.yml           # AWS Cloud Custodian policies
├── azure_policy.yml         # Azure Cloud Custodian policies
├── gcp_policy.yml           # GCP Cloud Custodian policies
├── custodian/               # Python virtual environment (created by script)
├── aws_output/              # AWS scan results (created by script)
├── azure_output/            # Azure scan results (created by script)
└── gcp_output/              # GCP scan results (created by script)
```

## 🎯 Usage

### Interactive Menu Options

1. **AWS** - Run Cloud Custodian for AWS
2. **Azure** - Run Cloud Custodian for Azure
3. **GCP** - Run Cloud Custodian for GCP
4. **All** - Run Cloud Custodian for all providers
5. **Setup only** - Install dependencies only
6. **Exit** - Quit the script

### Running Individual Providers

```bash
# Run AWS only
./test.sh
# Select option 1

# Run Azure only
./test.sh
# Select option 2

# Run GCP only
./test.sh
# Select option 3
```

## 📊 Policy Files

### AWS Policy (`aws_policy.yml`)
- S3 bucket public read/write access checks
- RDS backup retention period validation

### Azure Policy (`azure_policy.yml`)
- Storage account public access controls
- VM disk encryption verification
- Network Security Group default rules
- Key Vault public network access
- SQL Server public access controls

### GCP Policy (`gcp_policy.yml`)
- Storage bucket public access controls
- SQL instance public IP validation

## 📈 Output and Results

### Output Directories
- **aws_output/**: AWS scan results and reports
- **azure_output/**: Azure scan results and reports
- **gcp_output/**: GCP scan results and reports

### Report Formats
- JSON files with detailed findings
- HTML reports (if configured)
- CSV exports (if configured)

### Credential Management
- **Never commit credentials** to version control
- **Use IAM roles** when possible (AWS)
- **Rotate access keys** regularly
- **Use service accounts** for automation (GCP)

### Network Security
- **Use VPN** when accessing cloud resources
- **Restrict IP ranges** for API access
- **Enable MFA** for all accounts

## 📚 Additional Resources

### Documentation
- [Cloud Custodian Documentation](https://cloudcustodian.io/docs/)
- [AWS Cloud Custodian](https://cloudcustodian.io/docs/aws/)
- [Azure Cloud Custodian](https://cloudcustodian.io/docs/azure/)
- [GCP Cloud Custodian](https://cloudcustodian.io/docs/gcp/)


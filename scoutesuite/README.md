# ScoutSuite CSPM Scanner

This directory contains ScoutSuite configuration and scripts for Cloud Security Posture Management (CSPM) scanning of AWS and GCP environments.

## Overview

ScoutSuite is an open-source multi-cloud security-auditing tool that enables security posture assessment of cloud environments. This setup provides automated scanning capabilities for both AWS and GCP platforms.

## Files and Directories

### Scripts
- **`test.sh`** - Main execution script for running ScoutSuite scans
- **`README.md`** - This documentation file

### Directories
- **`scoutsuite_results/`** - Directory for scan output files (currently empty)
- **`scoutsuite-report/`** - Generated HTML reports and supporting files
  - **`scoutsuite-results/`** - JavaScript files containing scan data
    - `scoutsuite_results_aws-cv.js` (2.2MB) - AWS scan results
    - `scoutsuite_results_gcp-cloud-inventory-cspm.js` (1.4MB) - GCP scan results
    - `scoutsuite_exceptions_aws-cv.js` - AWS scan exceptions
    - `scoutsuite_exceptions_gcp-cloud-inventory-cspm.js` - GCP scan exceptions
  - **`inc-*/`** - Supporting libraries (Bootstrap, FontAwesome, jQuery, etc.)

## Usage

### Prerequisites
1. ScoutSuite installed (`pip install scoutsuite`)
2. AWS CLI configured with profile (default: `cv`)
3. GCP service account JSON file (`gcp.json`) in the parent directory

### Running Scans
```bash
# Make script executable
chmod +x test.sh

# Run the script
bash test.sh
```

The script will:
1. Prompt for confirmation before each cloud provider scan
2. Use AWS profile `cv` for AWS scanning
3. Use `gcp.json` service account credentials for GCP scanning
4. Generate HTML reports in the `scoutsuite-report/` directory

### Configuration
- **AWS Profile**: Set via `AWS_PROFILE` environment variable (default: `cv`)
- **GCP Credentials**: Expected at `../gcp.json` relative to the script location
- **Output Directory**: `./scoutsuite_results/` (created automatically)

## Scan Results

### AWS Scan
- **Target**: AWS account using configured CLI profile
- **Report**: `aws-cv.html` - Comprehensive security assessment
- **Data**: `scoutsuite_results_aws-cv.js` - Raw scan data

### GCP Scan
- **Target**: GCP project using service account credentials
- **Report**: `gcp-cloud-inventory-cspm.html` - Security posture assessment
- **Data**: `scoutsuite_results_gcp-cloud-inventory-cspm.js` - Raw scan data

## Features

- **Interactive Confirmation**: Script prompts before each scan
- **Error Handling**: Comprehensive error checking and logging
- **Flexible Configuration**: Environment variable support
- **Structured Output**: Organized report generation
- **Multi-Cloud Support**: AWS and GCP scanning capabilities

## Security Notes

- Ensure proper IAM permissions for AWS scanning
- Verify GCP service account has appropriate roles
- Review generated reports for security findings
- Store credentials securely and follow least privilege principles


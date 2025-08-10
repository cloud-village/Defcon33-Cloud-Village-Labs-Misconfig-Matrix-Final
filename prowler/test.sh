#!/bin/bash

# Title: Prowler CSPM Script for AWS, GCP, and Azure
# Author: Cloud Practitioner
# Description:
#   Runs Prowler against AWS, GCP, and Azure with manual confirmation.
#   - AWS: Uses configured CLI profile.
#   - GCP: Uses service account JSON from gcp.json in the current folder.
#   - Azure: Uses service principal from azure.json in the current folder.

set -euo pipefail

# =============================
# Configuration
# =============================
AWS_PROFILE="default"             # AWS named profile from CLI config
GCP_CREDENTIALS_FILE="../gcp.json"                 # GCP service account file (fixed name)
OUTPUT_DIR="./prowler_results"
DATE_TAG=$(date +%Y%m%d_%H%M%S)
AZURE_FILE="../azure.json"

# =============================
# Logging helpers
# =============================

log() {
    echo -e "[+] $1"
}

error() {
    echo -e "[ERROR] $1" >&2
    exit 1
}

prompt_continue() {
    read -rp "Do you want to continue to the $1 scan? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        log "Skipping $1 scan."
        return 1
    fi
    return 0
}

# =============================
# Prowler Installation Check
# =============================
check_and_install_prowler() {
    log "Checking if Prowler is installed..."
    
    if command -v prowler &> /dev/null; then
        log "Prowler is already installed."
        prowler --version
        return 0
    fi
    
    log "Prowler is not installed."
    read -rp "Do you want to install Prowler? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        error "Prowler is required to run this script. Please install it manually or run this script again and choose to install it."
    fi
    
    log "Installing Prowler..."
    
    # Check if pip is available
    if ! command -v pip3 &> /dev/null && ! command -v pip &> /dev/null; then
        error "pip is required to install Prowler. Please install pip first."
    fi
    
    # Try to install prowler using pip
    if command -v pip3 &> /dev/null; then
        pip3 install prowler
    elif command -v pip &> /dev/null; then
        pip install prowler
    else
        error "Could not find pip or pip3 to install Prowler."
    fi
    
    # Verify installation
    if command -v prowler &> /dev/null; then
        log "Prowler installed successfully!"
        prowler --version
    else
        error "Prowler installation failed. Please install it manually."
    fi
}

# =============================
# Setup
# =============================
setup() {
    mkdir -p "$OUTPUT_DIR"
    check_and_install_prowler
}

# =============================
# AWS Scan
# =============================
run_prowler_aws() {
    log "Preparing to run Prowler scan on AWS using profile: $AWS_PROFILE"

    if prompt_continue "AWS"; then
        prowler aws \
            --profile "$AWS_PROFILE" \
            --output-directory "$OUTPUT_DIR/aws_${DATE_TAG}"
        log "AWS scan completed. Results saved to $OUTPUT_DIR/aws_${DATE_TAG}"
    fi
}

# =============================
# GCP Scan
# =============================
run_prowler_gcp() {
    log "Preparing to run Prowler scan on GCP using credentials: $GCP_CREDENTIALS_FILE"

    if [[ ! -f "$GCP_CREDENTIALS_FILE" ]]; then
        error "GCP credentials file not found: $GCP_CREDENTIALS_FILE"
    fi

    if prompt_continue "GCP"; then
        prowler gcp \
            --credentials-file "$GCP_CREDENTIALS_FILE" \
            --output-directory "$OUTPUT_DIR/gcp_${DATE_TAG}" \
            
        log "GCP scan completed. Results saved to $OUTPUT_DIR/gcp_${DATE_TAG}"
    fi
}

# =============================
# Azure Environment Setup
# =============================
setup_azure_env() {
    log "Setting up Azure environment variables from $AZURE_FILE"
    
    if [[ ! -f "$AZURE_FILE" ]]; then
        error "Azure credentials file not found: $AZURE_FILE"
    fi
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        error "jq is required to parse Azure JSON file. Please install jq first."
    fi
    
    # Export all values from azure.json as environment variables
    export AZURE_CLIENT_ID=$(jq -r '.clientId' "$AZURE_FILE")
    export AZURE_CLIENT_SECRET=$(jq -r '.clientSecret' "$AZURE_FILE")
    export AZURE_SUBSCRIPTION_ID=$(jq -r '.subscriptionId' "$AZURE_FILE")
    export AZURE_TENANT_ID=$(jq -r '.tenantId' "$AZURE_FILE")
    export AZURE_AD_ENDPOINT=$(jq -r '.activeDirectoryEndpointUrl' "$AZURE_FILE")
    export AZURE_RESOURCE_MANAGER_ENDPOINT=$(jq -r '.resourceManagerEndpointUrl' "$AZURE_FILE")
    export AZURE_AD_GRAPH_RESOURCE_ID=$(jq -r '.activeDirectoryGraphResourceId' "$AZURE_FILE")
    export AZURE_SQL_MANAGEMENT_ENDPOINT=$(jq -r '.sqlManagementEndpointUrl' "$AZURE_FILE")
    export AZURE_GALLERY_ENDPOINT=$(jq -r '.galleryEndpointUrl' "$AZURE_FILE")
    export AZURE_MANAGEMENT_ENDPOINT=$(jq -r '.managementEndpointUrl' "$AZURE_FILE")
    
    log "Azure environment variables exported successfully"
    log "Client ID: ${AZURE_CLIENT_ID:0:8}..."
    log "Tenant ID: ${AZURE_TENANT_ID:0:8}..."
    log "Subscription ID: ${AZURE_SUBSCRIPTION_ID:0:8}..."
}

# =============================
# Azure Scan
# =============================
run_prowler_azure() {
    log "Preparing to run Prowler scan on Azure using service principal environment variables"

    if prompt_continue "Azure"; then
        setup_azure_env
        prowler azure \
            --sp-env-auth \
            --output-directory "$OUTPUT_DIR/azure_${DATE_TAG}"
            
        log "Azure scan completed. Results saved to $OUTPUT_DIR/azure_${DATE_TAG}"
    fi
}

# =============================
# Main
# =============================
main() {
    log "Starting Prowler CSPM scans."
    setup
    run_prowler_aws
    run_prowler_gcp
    run_prowler_azure
    log "All scans (if run) are complete. Review the reports in: $OUTPUT_DIR"
}

main "$@"

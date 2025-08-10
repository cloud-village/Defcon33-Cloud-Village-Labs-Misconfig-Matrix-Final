#!/bin/bash

# Cloud Custodian Automation Script
# This script automates the setup and execution of Cloud Custodian for AWS, GCP, and Azure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check Python version
check_python_version() {
    if command_exists python3; then
        PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}' | cut -d. -f1,2)
        PYTHON_MAJOR=$(echo $PYTHON_VERSION | cut -d. -f1)
        PYTHON_MINOR=$(echo $PYTHON_VERSION | cut -d. -f2)
        
        if [ "$PYTHON_MAJOR" -ge 3 ] && [ "$PYTHON_MINOR" -ge 8 ]; then
            print_status "Python $PYTHON_VERSION found - compatible"
            return 0
        else
            print_error "Python $PYTHON_VERSION found - requires Python 3.8 or higher"
            return 1
        fi
    else
        print_error "Python3 not found. Please install Python 3.8 or higher"
        return 1
    fi
}

# Function to setup virtual environment
setup_virtual_environment() {
    print_header "Setting up Cloud Custodian Virtual Environment"
    
    if [ -d "custodian" ]; then
        print_warning "Virtual environment 'custodian' already exists"
        read -p "Do you want to recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_status "Removing existing virtual environment..."
            rm -rf custodian
        else
            print_status "Using existing virtual environment"
            # Ensure packages are installed even if using existing environment
            source custodian/bin/activate
            install_cloud_custodian_packages
            return 0
        fi
    fi
    
    print_status "Creating Python virtual environment..."
    python3 -m venv custodian
    
    print_status "Activating virtual environment..."
    source custodian/bin/activate
    
    install_cloud_custodian_packages
    
    print_status "Virtual environment setup complete!"
}

# Function to install Cloud Custodian packages
install_cloud_custodian_packages() {
    print_status "Upgrading pip..."
    pip install --upgrade pip
    
    print_status "Installing Cloud Custodian core (AWS support)..."
    pip install c7n
    
    print_status "Installing Cloud Custodian Azure support..."
    pip install c7n_azure
    
    print_status "Installing Cloud Custodian GCP support..."
    pip install c7n_gcp
    
    print_status "All Cloud Custodian packages installed successfully!"
}

# Function to verify Cloud Custodian packages are installed
verify_cloud_custodian_packages() {
    print_status "Verifying Cloud Custodian packages..."
    
    # Check if c7n is installed
    if ! python -c "import c7n" 2>/dev/null; then
        print_error "c7n package not found. Installing..."
        pip install c7n
    fi
    
    # Check if c7n_azure is installed
    if ! python -c "import c7n_azure" 2>/dev/null; then
        print_error "c7n_azure package not found. Installing..."
        pip install c7n_azure
    fi
    
    # Check if c7n_gcp is installed
    if ! python -c "import c7n_gcp" 2>/dev/null; then
        print_error "c7n_gcp package not found. Installing..."
        pip install c7n_gcp
    fi
    
    print_status "All Cloud Custodian packages verified!"
}

# Function to check cloud provider credentials
check_aws_credentials() {
    print_status "Checking AWS credentials..."
    if command_exists aws; then
        if aws sts get-caller-identity >/dev/null 2>&1; then
            print_status "AWS credentials are configured and working"
            return 0
        else
            print_warning "AWS CLI is installed but credentials are not configured or invalid"
            return 1
        fi
    else
        print_warning "AWS CLI not found. Please install AWS CLI and configure credentials"
        return 1
    fi
}

check_azure_credentials() {
    print_status "Checking Azure credentials..."
    
    # Check if azure.json file exists
    if [ ! -f "../azure.json" ]; then
        print_error "Azure credentials file ../azure.json not found"
        return 1
    fi
    
    # Check if jq is available for JSON parsing
    if ! command_exists jq; then
        print_error "jq is required to parse azure.json. Please install jq first."
        return 1
    fi
    
    # Read and export Azure credentials from JSON file
    print_status "Reading Azure credentials from ../azure.json..."
    
    # Export Azure environment variables from JSON
    export AZURE_CLIENT_ID=$(jq -r '.clientId' ../azure.json)
    export AZURE_CLIENT_SECRET=$(jq -r '.clientSecret' ../azure.json)
    export AZURE_SUBSCRIPTION_ID=$(jq -r '.subscriptionId' ../azure.json)
    export AZURE_TENANT_ID=$(jq -r '.tenantId' ../azure.json)
    export AZURE_AD_ENDPOINT=$(jq -r '.activeDirectoryEndpointUrl' ../azure.json)
    export AZURE_RESOURCE_MANAGER_ENDPOINT=$(jq -r '.resourceManagerEndpointUrl' ../azure.json)
    export AZURE_AD_GRAPH_RESOURCE_ID=$(jq -r '.activeDirectoryGraphResourceId' ../azure.json)
    export AZURE_SQL_MANAGEMENT_ENDPOINT=$(jq -r '.sqlManagementEndpointUrl' ../azure.json)
    export AZURE_GALLERY_ENDPOINT=$(jq -r '.galleryEndpointUrl' ../azure.json)
    export AZURE_MANAGEMENT_ENDPOINT=$(jq -r '.managementEndpointUrl' ../azure.json)
    
    # Verify that required credentials are set
    if [ -z "$AZURE_CLIENT_ID" ] || [ -z "$AZURE_CLIENT_SECRET" ] || [ -z "$AZURE_SUBSCRIPTION_ID" ] || [ -z "$AZURE_TENANT_ID" ]; then
        print_error "Required Azure credentials are missing from ../azure.json"
        return 1
    fi
    
    print_status "Azure credentials configured using ../azure.json"
    print_status "Client ID: $AZURE_CLIENT_ID"
    print_status "Subscription ID: $AZURE_SUBSCRIPTION_ID"
    print_status "Tenant ID: $AZURE_TENANT_ID"
    
    return 0
}

check_gcp_credentials() {
    print_status "Checking GCP credentials..."
    
    # Check if gcp.json file exists
    if [ ! -f "../gcp.json" ]; then
        print_error "GCP service account key file ../gcp.json not found"
        return 1
    fi
    
    # Set GOOGLE_APPLICATION_CREDENTIALS environment variable
    export GOOGLE_APPLICATION_CREDENTIALS="$(pwd)/../gcp.json"
    print_status "GCP credentials configured using ../gcp.json"
    return 0
}

# Function to run Cloud Custodian for AWS
run_aws_custodian() {
    print_header "Running Cloud Custodian for AWS"
    
    if ! check_aws_credentials; then
        print_error "AWS credentials not properly configured. Please configure AWS CLI first."
        return 1
    fi
    
    # Check if aws_policy.yml exists
    if [ ! -f "aws_policy.yml" ]; then
        print_error "aws_policy.yml file not found. Please create an aws_policy.yml file with your AWS Cloud Custodian policies."
        return 1
    fi
    
    print_status "Running Cloud Custodian for AWS..."
    custodian run --output-dir=aws_output aws_policy.yml
    print_status "AWS Cloud Custodian run completed. Check aws_output/ directory for results."
}

# Function to run Cloud Custodian for Azure
run_azure_custodian() {
    print_header "Running Cloud Custodian for Azure"
    
    if ! check_azure_credentials; then
        print_error "Azure credentials not properly configured. Please ensure ../azure.json file exists and contains valid credentials."
        return 1
    fi
    
    # Check if azure_policy.yml exists
    if [ ! -f "azure_policy.yml" ]; then
        print_error "azure_policy.yml file not found. Please create an azure_policy.yml file with your Azure Cloud Custodian policies."
        return 1
    fi
    
    print_status "Running Cloud Custodian for Azure..."
    print_status "Using Azure credentials from: ../azure.json"
    custodian run --output-dir=azure_output azure_policy.yml
    print_status "Azure Cloud Custodian run completed. Check azure_output/ directory for results."
}

# Function to run Cloud Custodian for GCP
run_gcp_custodian() {
    print_header "Running Cloud Custodian for GCP"
    
    if ! check_gcp_credentials; then
        print_error "GCP credentials not properly configured. Please ensure ../gcp.json file exists."
        return 1
    fi
    
    # Check if gcp_policy.yml exists
    if [ ! -f "gcp_policy.yml" ]; then
        print_error "gcp_policy.yml file not found. Please create a gcp_policy.yml file with your GCP Cloud Custodian policies."
        return 1
    fi
    
    print_status "Running Cloud Custodian for GCP..."
    print_status "Using GCP credentials from: $GOOGLE_APPLICATION_CREDENTIALS"
    GOOGLE_CLOUD_PROJECT="cloud-inventory-cspm" custodian run --output-dir=gcp_output gcp_policy.yml
    print_status "GCP Cloud Custodian run completed. Check gcp_output/ directory for results."
}

# Function to show menu and get user choice
show_menu() {
    print_header "Cloud Custodian Automation"
    echo "Please select a cloud provider to run Cloud Custodian:"
    echo "1) AWS"
    echo "2) Azure"
    echo "3) GCP"
    echo "4) All (AWS, Azure, GCP)"
    echo "5) Setup only (install dependencies)"
    echo "6) Exit"
    echo
}

# Main execution
main() {
    print_header "Cloud Custodian Automation Script"
    
    # Check Python version
    if ! check_python_version; then
        print_error "Python version check failed. Exiting."
        exit 1
    fi
    
    # Setup virtual environment
    setup_virtual_environment
    
    # Ensure virtual environment is activated for all operations
    if [[ "$VIRTUAL_ENV" != *"custodian"* ]]; then
        print_status "Activating virtual environment..."
        source custodian/bin/activate
    fi
    
    # Verify all required packages are installed
    verify_cloud_custodian_packages
    
    # Show menu and get user choice
    while true; do
        show_menu
        read -p "Enter your choice (1-6): " choice
        
        case $choice in
            1)
                run_aws_custodian
                ;;
            2)
                run_azure_custodian
                ;;
            3)
                run_gcp_custodian
                ;;
            4)
                print_header "Running Cloud Custodian for All Providers"
                run_aws_custodian
                run_azure_custodian
                run_gcp_custodian
                print_status "All Cloud Custodian runs completed!"
                ;;
            5)
                print_status "Setup completed. Virtual environment is ready."
                ;;
            6)
                print_status "Exiting..."
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter a number between 1 and 6."
                ;;
        esac
        
        echo
        read -p "Press Enter to continue..."
        echo
    done
}

# Check if script is being sourced or executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi

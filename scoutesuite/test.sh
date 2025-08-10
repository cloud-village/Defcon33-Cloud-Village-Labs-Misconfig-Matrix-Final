
#!/bin/bash

# Title: ScoutSuite CSPM Script for AWS, GCP, and Azure
# Author: Cloud Practitioner
# Description:
#   Runs ScoutSuite against AWS, GCP, and Azure with manual confirmation.
#   - AWS: Uses configured CLI profile.
#   - GCP: Uses service account JSON from gcp.json in the current folder.
#   - Azure: Uses credentials from azure.json in the current folder.

set -euo pipefail

# =============================
# Configuration
# =============================
AWS_PROFILE="default"                  # Default AWS profile
GCP_CREDENTIALS_FILE="../gcp.json"                 # GCP service account file
AZURE_CREDENTIALS_FILE="../azure.json"             # Azure credentials file
OUTPUT_DIR="./scoutsuite_results"
DATE_TAG=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR"

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

warn() {
    echo -e "[WARNING] $1" >&2
}

prompt_continue() {
    read -rp "Do you want to run ScoutSuite for $1? (y/n): " choice
    if [[ "$choice" != "y" && "$choice" != "Y" ]]; then
        log "Skipping $1 scan."
        return 1
    fi
    return 0
}

prompt_yes_no() {
    read -rp "$1 (y/n): " choice
    if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
        return 0
    fi
    return 1
}

# =============================
# Setup and Installation
# =============================

check_command() {
    if command -v "$1" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

check_python() {
    if check_command python3; then
        PYTHON_CMD="python3"
        return 0
    elif check_command python; then
        PYTHON_CMD="python"
        return 0
    else
        return 1
    fi
}

check_pip() {
    if check_command pip3; then
        PIP_CMD="pip3"
        return 0
    elif check_command pip; then
        PIP_CMD="pip"
        return 0
    else
        return 1
    fi
}

install_scoutsuite() {
    log "Installing ScoutSuite using virtual environment..."
    
    if ! check_python; then
        error "Python is not installed. Please install Python 3.7+ first."
    fi
    
    log "Using Python: $PYTHON_CMD"
    
    # Check Python version
    PYTHON_VERSION=$($PYTHON_CMD --version 2>&1 | cut -d' ' -f2)
    log "Python version: $PYTHON_VERSION"
    
    # Check and install virtualenv if needed
    if ! check_command virtualenv; then
        log "virtualenv is not installed. Installing virtualenv..."
        
        if ! check_pip; then
            error "pip is not installed. Please install pip first."
        fi
        
        log "Using pip: $PIP_CMD"
        
        if $PIP_CMD install virtualenv; then
            log "virtualenv installed successfully!"
        else
            error "Failed to install virtualenv. Please check your internet connection and try again."
        fi
    else
        log "virtualenv is already installed."
    fi
    
    # Create virtual environment
    log "Creating virtual environment..."
    if virtualenv -p python3 venv; then
        log "Virtual environment created successfully!"
    else
        error "Failed to create virtual environment. Please check your Python installation."
    fi
    
    # Activate virtual environment
    log "Activating virtual environment..."
    if source venv/bin/activate; then
        log "Virtual environment activated!"
    else
        error "Failed to activate virtual environment."
    fi
    
    # Install ScoutSuite in virtual environment
    log "Installing ScoutSuite in virtual environment..."
    if venv/bin/pip install scoutsuite; then
        log "ScoutSuite installed successfully in virtual environment!"
        
            # Test installation
    log "Testing ScoutSuite installation..."
    if venv/bin/scout --help >/dev/null 2>&1; then
        log "ScoutSuite installation verified successfully!"
        
        # Create activation helper script
        cat > activate_scoutsuite.sh << 'EOF'
#!/bin/bash
# ScoutSuite Virtual Environment Activation Script
echo "Activating ScoutSuite virtual environment..."
source venv/bin/activate
echo "ScoutSuite virtual environment is now active!"
echo "You can now run: scout --help"
echo "To deactivate, run: deactivate"
EOF
        chmod +x activate_scoutsuite.sh
        log "Created activation script: ./activate_scoutsuite.sh"
        
        return 0
    else
        error "ScoutSuite installation test failed."
    fi
    else
        error "Failed to install ScoutSuite. Please check your internet connection and try again."
    fi
}

check_scoutsuite() {
    # Check if ScoutSuite is available globally
    if check_command scout; then
        log "ScoutSuite is already installed globally."
        return 0
    fi
    
    # Check if ScoutSuite is available in virtual environment
    if [[ -f "venv/bin/scout" ]]; then
        log "ScoutSuite is available in virtual environment."
        return 0
    fi
    
    return 1
}

setup_check() {
    log "Performing setup check..."
    
    # Check if ScoutSuite is installed
    if check_scoutsuite; then
        log "ScoutSuite is ready to use."
        return 0
    fi
    
    warn "ScoutSuite is not installed."
    
    if prompt_yes_no "Do you want to install ScoutSuite now?"; then
        install_scoutsuite
        log "Setup complete! ScoutSuite is now ready to use."
    else
        error "ScoutSuite is required to run this script. Please install it manually or run this script again and choose to install."
    fi
}

# =============================
# AWS Scan
# =============================
run_scoutsuite_aws() {
    log "Preparing to run ScoutSuite for AWS using profile: $AWS_PROFILE"

    # Determine which scout command to use
    if [[ -f "venv/bin/scout" ]]; then
        SCOUT_CMD="venv/bin/scout"
        log "Using ScoutSuite from virtual environment"
    else
        SCOUT_CMD="scout"
        log "Using ScoutSuite from global installation"
    fi

    if prompt_continue "AWS"; then
        $SCOUT_CMD aws --profile "$AWS_PROFILE" || error "ScoutSuite AWS scan failed"
        log "AWS scan completed."
    fi
}

# =============================
# GCP Scan
# =============================
run_scoutsuite_gcp() {
    log "Preparing to run ScoutSuite for GCP using credentials: $GCP_CREDENTIALS_FILE"

    if [[ ! -f "$GCP_CREDENTIALS_FILE" ]]; then
        error "GCP credentials file not found: $GCP_CREDENTIALS_FILE"
    fi

    # Determine which scout command to use
    if [[ -f "venv/bin/scout" ]]; then
        SCOUT_CMD="venv/bin/scout"
        log "Using ScoutSuite from virtual environment"
    else
        SCOUT_CMD="scout"
        log "Using ScoutSuite from global installation"
    fi

    if prompt_continue "GCP"; then
        $SCOUT_CMD gcp -s "$GCP_CREDENTIALS_FILE" || error "ScoutSuite GCP scan failed"
        log "GCP scan completed."
    fi
}

# =============================
# Azure Scan
# =============================
run_scoutsuite_azure() {
    log "Preparing to run ScoutSuite for Azure using credentials: $AZURE_CREDENTIALS_FILE"

    if [[ ! -f "$AZURE_CREDENTIALS_FILE" ]]; then
        error "Azure credentials file not found: $AZURE_CREDENTIALS_FILE"
    fi

    # Determine which scout command to use
    if [[ -f "venv/bin/scout" ]]; then
        SCOUT_CMD="venv/bin/scout"
        log "Using ScoutSuite from virtual environment"
    else
        SCOUT_CMD="scout"
        log "Using ScoutSuite from global installation"
    fi

    if prompt_continue "Azure"; then
        $SCOUT_CMD azure --file-auth "$AZURE_CREDENTIALS_FILE" 
        log "Azure scan completed."
    fi
}

# =============================
# Main
# =============================
main() {
    log "Starting ScoutSuite CSPM Scanner"
    log "=================================="
    
    # Run setup check first
    setup_check
    
    log "Starting ScoutSuite scans."
    run_scoutsuite_aws
    run_scoutsuite_gcp
    run_scoutsuite_azure
    log "All scans (if run) are complete."
}

main "$@"

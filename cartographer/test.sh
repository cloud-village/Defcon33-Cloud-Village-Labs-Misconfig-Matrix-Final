#!/bin/bash

# Title: Automated Cartography Setup and Cloud Provider Scan
# Description:
#   Clone Cartography, replace entrypoint, build Docker image, run Neo4j, and scan AWS or GCP.

set -euo pipefail

REPO_URL="https://github.com/cartography-cncf/cartography.git"
REPO_DIR="cartography"
ENTRYPOINT_FILE="dev-entrypoint.sh"
AWS_PROFILE="default"
AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION:-us-east-1}"
#NEO4J_URI="bolt://cartography-neo4j-1:7687"
NEO4J_URI="bolt://neo4j:7687"
NEO4J_BROWSER_URL="http://localhost:7474"
GCP_CREDENTIALS_FILE="${GCP_CREDENTIALS_FILE:-../gcp.json}"

log() {
    echo -e "[+] $1"
}

error() {
    echo -e "[ERROR] $1" >&2
    exit 1
}

# Function to prompt user for cloud provider choice
prompt_for_provider() {
    echo
    echo "=============================================="
    echo "🌐 Choose Cloud Provider to Scan:"
    echo "   1) AWS"
    echo "   2) Exit"
    echo "=============================================="
    
    while true; do
        read -p "Enter your choice (1-4): " choice
        case $choice in
            1)
                PROVIDER="aws"
                break
                ;;
            2)
                log "Exiting..."
                exit 0
                ;;
            *)
                echo "Invalid choice. Please enter 1, 2, 3, or 4."
                ;;
        esac
    done
    
    log "Selected provider: $PROVIDER"
}

# Step 1: Clone the repo
clone_repo() {
    if [ -d "$REPO_DIR" ]; then
        log "Repository already cloned. Skipping clone step."
    else
        log "Cloning Cartography repository..."
        git clone "$REPO_URL" "$REPO_DIR"
    fi
}

# Step 2: Replace dev-entrypoint.sh
replace_entrypoint() {
    log "Replacing dev-entrypoint.sh..."

    cat <<'EOF' > "$REPO_DIR/$ENTRYPOINT_FILE"
#!/bin/sh
while ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; do
  echo "Waiting for Git to be ready..."
  sleep 1
done

# Create the virtual environment if it doesn't exist
if [ ! -f .venv/bin/activate ]; then
  echo "Creating virtual environment..."
  python3 -m venv .venv
  . .venv/bin/activate
  pip install -r requirements.txt || pip install -r dev-requirements.txt
else
  # Activate the virtual environment
  . .venv/bin/activate
fi

# Pass control to main container command
exec "$@"
EOF

    chmod +x "$REPO_DIR/$ENTRYPOINT_FILE"
    log "dev-entrypoint.sh replaced successfully."
}

# Step 3: Build Docker
build_docker() {
    log "Building Docker Compose images..."
    docker-compose -f "$REPO_DIR/docker-compose.yml" build
    log "Docker Compose build complete."
}

# Step 4: Start Neo4j
start_neo4j() {
    log "Starting Neo4j container..."
    docker-compose -f "$REPO_DIR/docker-compose.yml" up -d --remove-orphans
}

# Step 5: Wait for Neo4j to be ready
# wait_for_neo4j() {
#     log "Waiting for Neo4j to become available..."

#     MAX_RETRIES=30
#     COUNT=0

#     until docker exec "$(docker ps --filter name=neo4j --format "{{.ID}}")" curl -s http://localhost:7474 > /dev/null 2>&1; do
#         COUNT=$((COUNT+1))
#         if [ "$COUNT" -ge "$MAX_RETRIES" ]; then
#             error "Neo4j did not become ready in time."
#         fi
#         sleep 2
#     done

#     log "Neo4j is ready at $NEO4J_BROWSER_URL"
# }

# Step 6: Run Cartography for AWS
# run_cartography_aws() {
#     log "Running Cartography scan against AWS..."
#     log "Using AWS profile: $AWS_PROFILE, region: $AWS_DEFAULT_REGION"
    
#     docker-compose -f "$REPO_DIR/docker-compose.yml" run \
#         -e AWS_PROFILE="$AWS_PROFILE" \
#         -e AWS_DEFAULT_REGION="$AWS_DEFAULT_REGION" \
#         cartography --selected-modules aws --neo4j-uri "$NEO4J_URI"
    
#     log "AWS Cartography scan complete."
# }

# Step 7: Run Cartography for GCP
run_cartography_gcp() {
    log "Running Cartography scan against GCP..."
    log "Using GCP credentials file: $GCP_CREDENTIALS_FILE"
    
    # Check if GCP credentials file exists
    if [[ ! -f "$GCP_CREDENTIALS_FILE" ]]; then
        error "GCP credentials file not found at $GCP_CREDENTIALS_FILE"
    fi
    
    # Convert to absolute path if it's a relative path
    if [[ ! "$GCP_CREDENTIALS_FILE" = /* ]]; then
        GCP_CREDENTIALS_FILE=$(realpath "$GCP_CREDENTIALS_FILE")
    fi
    
    docker-compose -f "$REPO_DIR/docker-compose.yml" run \
        --rm \
        -v "$GCP_CREDENTIALS_FILE:/tmp/gcp.json:ro" \
        -e GOOGLE_APPLICATION_CREDENTIALS="/tmp/gcp.json" \
        cartography \
        --selected-modules gcp \
        --neo4j-uri "$NEO4J_URI"
    
    log "GCP Cartography scan complete."
}

# Step 8: Run selected scans
run_selected_scans() {
    case $PROVIDER in
        # "aws")
        #     run_cartography_aws
        #     ;;
        "gcp")
            run_cartography_gcp
            ;;
        "both")
            log "Running both AWS and GCP scans..."
            run_cartography_aws
            run_cartography_gcp
            ;;
    esac
    
    log "Selected scans completed."
}

# Step 9: Final message
post_run_message() {
    echo
    echo "=============================================="
    echo "🧠 View the Graph in Neo4j Browser:"
    echo "   $NEO4J_BROWSER_URL"
    echo
    echo "💡 Try sample queries:"
    if [[ "$PROVIDER" == "aws" || "$PROVIDER" == "both" ]]; then
        echo "   # AWS Resources:"
        echo "   match (i:AWSRole)--(c:AWSAccount) return *"
        echo "   match (i:AWSInstance)--(c:AWSAccount) return *"
    fi
    if [[ "$PROVIDER" == "gcp" || "$PROVIDER" == "both" ]]; then
        echo "   # GCP Resources:"
        echo "   match (i:GCPInstance)--(c:GCPProject) return *"
        echo "   match (i:GCPRole)--(c:GCPProject) return *"
    fi
    if [[ "$PROVIDER" == "both" ]]; then
        echo "   # Cross-cloud:"
        echo "   match (n) return labels(n), count(n)"
    fi
    echo "=============================================="
    echo
}

main() {
    log "Starting Cartography setup..."
    clone_repo
    replace_entrypoint
    build_docker
    start_neo4j
    # wait_for_neo4j
    
    # Prompt user for provider choice
    prompt_for_provider
    
    # Run selected scans
    run_selected_scans
    post_run_message
}

main "$@"

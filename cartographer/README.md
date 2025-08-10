Cartographer - Cloud Infrastructure Mapping Tool

## What is Cartographer?

Cartographer is like a detective for your cloud infrastructure. It automatically discovers and maps out all the resources in your AWS account (like servers, databases, networks, and how they're connected) and creates a visual graph that you can explore in Neo4j.

Think of it as creating a detailed map of your cloud environment - showing you what's there, how things are connected, and helping you understand your infrastructure better.

## 🚀 Quick Start

### Prerequisites
- Docker and Docker Compose installed
- AWS credentials configured (either through AWS CLI or environment variables)
- Git

### Installing Docker and Docker Compose

**For Windows:**
1. Download Docker Desktop from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Install Docker Desktop (this includes both Docker and Docker Compose)
3. Start Docker Desktop and wait for it to be running

**For macOS:**
1. Download Docker Desktop from [https://www.docker.com/products/docker-desktop](https://www.docker.com/products/docker-desktop)
2. Install Docker Desktop (this includes both Docker and Docker Compose)
3. Start Docker Desktop and wait for it to be running

**For Ubuntu/Debian Linux:**
```bash
# Update package index
sudo apt update

# Install Docker
sudo apt install docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (optional, to run docker without sudo)
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

**For CentOS/RHEL/Fedora:**
```bash
# Install Docker
sudo dnf install docker
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (optional)
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verify installation
docker --version
docker-compose --version
```

### Running the Tool

1. **Clone and Setup** (if you haven't already):
   ```bash
   ./test.sh
   ```

Incase there are errors with docker compose run this below: 

```
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

   This script will:
   - Clone the Cartography repository
   - Set up the necessary files
   - Build the Docker containers
   - Start Neo4j database
   - Run a scan of your infrastructure

2. **View Your Infrastructure Map**:
   - Open your browser and go to: `http://localhost:7474`
   - This opens the Neo4j browser where you can explore your infrastructure graph

## 🔍 What You'll See

After running the scan, you'll have a visual graph showing:
- **AWS Accounts** - Your cloud accounts
- **EC2 Instances** - Virtual servers
- **Security Groups** - Firewall rules
- **IAM Roles & Users** - Who can access what
- **VPCs & Subnets** - Network structure
- **Databases** - RDS instances
- **Load Balancers** - Traffic distribution
- **And much more!**

## 🎯 Sample Queries to Try

Once you're in the Neo4j browser, try these queries to explore your infrastructure:

```cypher
// Find all EC2 instances
MATCH (i:EC2Instance) RETURN i

// See which instances are in which security groups
MATCH (i:EC2Instance)-[:MEMBER_OF_EC2_SECURITY_GROUP]->(sg:EC2SecurityGroup) 
RETURN i, sg

// Find IAM roles and their permissions
MATCH (r:AWSRole)-[:POLICY]->(p:AWSPolicy) 
RETURN r, p

// Discover network connections
MATCH (vpc:VPC)-[:RESOURCE]->(subnet:Subnet) 
RETURN vpc, subnet
```

## 🛠️ Configuration

The tool uses these default settings:
- **AWS Profile**: `1234_testprofile` (you can change this in the script)
- **AWS Region**: `us-east-1` (you can change this in the script)
- **Neo4j URL**: `bolt://cartography-neo4j-1:7687`
- **Neo4j Browser**: `http://localhost:7474`

## 🧹 Cleanup

To stop the containers when you're done:
```bash
cd cartography
docker-compose down
```

## 🤔 Why Use Cartographer?

- **Security Audits**: Find misconfigurations and security gaps
- **Compliance**: Understand your infrastructure for compliance reports
- **Documentation**: Automatically generate infrastructure documentation
- **Troubleshooting**: Visualize relationships between resources
- **Cost Optimization**: See what resources you have and how they're connected



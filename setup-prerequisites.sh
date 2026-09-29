#!/bin/bash

# ============================================================================
# SOC-CyberDeck Prerequisites Setup Script
# ============================================================================
# Complete prerequisites installation for SOC-CyberDeck Platform
# Run this entire block on any Ubuntu system (AWS, VMware, VirtualBox, bare metal)
#
# Usage: ./setup-prerequisites.sh [OPTIONS]
# Options:
#   --help    Show this help message
#   --force   Skip confirmation prompts
# ============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
FORCE=false

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --force)
            FORCE=true
            shift
            ;;
        --help)
            echo -e "${BLUE}SOC-CyberDeck Prerequisites Setup Script${NC}"
            echo "============================================"
            echo ""
            echo "This script installs all prerequisites for SOC-CyberDeck Platform:"
            echo "• Docker CE (latest)"
            echo "• Docker Compose (latest)"
            echo "• System optimizations"
            echo "• Network configuration"
            echo "• User permissions"
            echo ""
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --force   Skip confirmation prompts"
            echo "  --help    Show this help message"
            echo ""
            echo "Supported Platforms:"
            echo "• AWS EC2 (Ubuntu 22.04+)"
            echo "• VMware/VirtualBox (Ubuntu 22.04+)"
            echo "• Bare metal Ubuntu systems"
            echo ""
            exit 0
            ;;
        *)
            echo -e "${RED}❌ Unknown option: $1${NC}"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

echo ""
echo -e "${BLUE}===== COMPLETE SOC-CyberDeck PREREQUISITES SETUP =====${NC}"
echo -e "${CYAN}Run this entire block on any Ubuntu system (AWS, VMware, VirtualBox, bare metal)${NC}"
echo ""

if [ "$FORCE" != "true" ]; then
    echo -e "${YELLOW}⚠️  This script will install Docker, Docker Compose, and configure your system${NC}"
    echo "Press Enter to continue, or Ctrl+C to cancel..."
    read -r
fi

echo ""
echo -e "${BLUE}🔄 1. System Update and Basic Packages${NC}"
echo "   Updating system packages and installing essential tools..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release git
echo -e "${GREEN}✅ System packages updated successfully${NC}"

echo ""
echo -e "${BLUE}🐳 2. Docker Installation (Latest)${NC}"
echo "   Installing Docker CE with official repository..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo -e "${GREEN}✅ Docker installed successfully${NC}"

echo ""
echo -e "${BLUE}📦 3. Docker Compose (Latest - Important for VMware/VirtualBox)${NC}"
echo "   Installing standalone Docker Compose binary..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo -e "${GREEN}✅ Docker Compose installed successfully${NC}"

echo ""
echo -e "${BLUE}👤 4. User Permissions and Docker Setup${NC}"
echo "   Configuring user permissions and Docker service..."
sudo usermod -aG docker $USER
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
sudo systemctl enable docker && sudo systemctl start docker
echo -e "${GREEN}✅ Docker permissions and service configured${NC}"

echo ""
echo -e "${BLUE}⚙️  5. System Optimizations for Containers${NC}"
echo "   Applying system optimizations for container workloads..."
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf
echo -e "${GREEN}✅ System optimizations applied${NC}"

echo ""
echo -e "${BLUE}🌍 6. Environment Variables (Prevents VMware/VirtualBox warnings)${NC}"
echo "   Setting up Docker build environment variables..."
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
echo 'export COMPOSE_DOCKER_CLI_BUILD=1' >> ~/.bashrc
echo -e "${GREEN}✅ Environment variables configured${NC}"

echo ""
echo -e "${BLUE}🔧 7. Docker Networking Configuration (Prevents common networking errors)${NC}"
echo "🔧 Configuring Docker networking to prevent installation errors..."

# Configure Docker daemon for better networking
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<'DAEMON_EOF'
{
  "iptables": true,
  "userland-proxy": false,
  "live-restore": true,
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
DAEMON_EOF

# Reset iptables to prevent conflicts (common cause of networking errors)
sudo iptables -t nat -F 2>/dev/null || true
sudo iptables -t mangle -F 2>/dev/null || true
sudo iptables -F 2>/dev/null || true
sudo iptables -X 2>/dev/null || true

# Restart Docker with new configuration
sudo systemctl restart docker
sleep 5

# Clean any existing Docker networks that might conflict
sudo docker network prune -f 2>/dev/null || true
echo -e "${GREEN}✅ Docker networking configured successfully${NC}"

echo ""
echo -e "${BLUE}🔍 8. Port Conflict Prevention${NC}"
echo "🔍 Checking for potential port conflicts..."
REQUIRED_PORTS="5443 7000 7001 7002 7003 7004 7005 7006 7007 7008 7009 7010 7011 7012 7013 7014 7015 9200 9443 1514 1515 55000"
CONFLICTS=()

for port in $REQUIRED_PORTS; do
    if sudo ss -tulpn 2>/dev/null | grep -q ":$port "; then
        CONFLICTS+=($port)
    fi
done

if [ ${#CONFLICTS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️ WARNING: The following ports are already in use: ${CONFLICTS[*]}${NC}"
    echo "   These may cause conflicts during SOC-CyberDeck deployment"
    echo "   Consider stopping services using these ports or rebooting if needed"
else
    echo -e "${GREEN}✅ All required ports are available${NC}"
fi

echo ""
echo -e "${BLUE}🔐 9. Apply Docker group and test access${NC}"
echo "   Testing Docker group permissions..."
newgrp docker << 'EOF'
# Test Docker access within new group context
docker --version >/dev/null 2>&1 && echo "✅ Docker access confirmed" || echo "⚠️ Docker access issue - logout/login may be required"
EOF

echo ""
echo -e "${BLUE}✅ 10. Verify Installation${NC}"
echo "🔍 Verifying installation..."
docker --version || echo -e "${YELLOW}⚠️ Docker version check failed${NC}"
docker compose version || echo -e "${YELLOW}⚠️ Docker Compose version check failed${NC}"

echo ""
echo -e "${BLUE}🔬 11. Final Docker access and networking test${NC}"
if docker ps >/dev/null 2>&1; then
    echo -e "${GREEN}✅ Docker daemon access confirmed - no logout required!${NC}"
    # Test Docker networking capability
    if docker network ls >/dev/null 2>&1; then
        echo -e "${GREEN}✅ Docker networking confirmed - ready for SOC-CyberDeck deployment!${NC}"
    else
        echo -e "${YELLOW}⚠️ Docker networking issue detected - may need system reboot${NC}"
    fi
elif sudo docker ps >/dev/null 2>&1; then
    echo -e "${YELLOW}⚠️ Docker requires sudo - logout/login recommended for group permissions${NC}"
else
    echo -e "${RED}❌ Docker daemon not accessible - check installation${NC}"
fi

echo ""
echo -e "${GREEN}🎉 ============================================${NC}"
echo -e "${GREEN}✅ Prerequisites setup complete!${NC}"
echo -e "${GREEN}🚀 Ready to clone and deploy SOC-CyberDeck${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${CYAN}📋 Next Steps:${NC}"
echo "1. Clone SOC-CyberDeck: git clone https://github.com/SOC-CyberDeck0/SOC-CyberDeck.git"
echo "2. Enter directory: cd SOC-CyberDeck"
echo "3. Run installation: ./SOC-CyberDeck_init.sh"
echo ""
echo -e "${YELLOW}💡 Note: If Docker commands still require sudo, logout and login again${NC}"
echo ""

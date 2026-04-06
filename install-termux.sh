#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw Termux Installation Script for Samsung S6 Lite
# This script sets up OpenClaw to run 24/7 in the background on Android via Termux

set -e

echo "========================================"
echo "OpenClaw Termux Installer"
echo "Optimized for Samsung S6 Lite Tablet"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running in Termux
if [ ! -d "/data/data/com.termux" ]; then
    echo -e "${RED}Error: This script must be run in Termux!${NC}"
    exit 1
fi

echo -e "${GREEN}Step 1: Updating Termux packages...${NC}"
pkg update -y
pkg upgrade -y

echo -e "${GREEN}Step 2: Installing required packages...${NC}"
# Install Node.js 24 (or fallback to available version)
pkg install -y nodejs-lts git python build-essential

# Install termux-services for background operation
pkg install -y termux-services

# Restart termux-services
if [ -d "$PREFIX/var/service" ]; then
    sv-enable sshd 2>/dev/null || true
fi

# Install additional utilities
pkg install -y jq curl wget procps

echo -e "${GREEN}Step 3: Verifying Node.js installation...${NC}"
node --version
npm --version

# Install pnpm globally
echo -e "${GREEN}Step 4: Installing pnpm package manager...${NC}"
npm install -g pnpm

echo -e "${GREEN}Step 5: Cloning OpenClaw repository...${NC}"
cd ~
if [ -d "openclaw" ]; then
    echo -e "${YELLOW}OpenClaw directory exists. Updating...${NC}"
    cd openclaw
    git pull
else
    git clone https://github.com/openclaw/openclaw.git
    cd openclaw
fi

echo -e "${GREEN}Step 6: Installing OpenClaw dependencies...${NC}"
# Set npm config to avoid issues on Android
npm config set prefer-offline true
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# Install dependencies
pnpm install

echo -e "${GREEN}Step 7: Building OpenClaw UI and core...${NC}"
pnpm ui:build
pnpm build

echo -e "${GREEN}Step 8: Setting up Termux service...${NC}"
# Create service directory
mkdir -p ~/.config/openclaw
mkdir -p $PREFIX/var/service/openclaw

# Copy service configuration
cp $(dirname "$0")/termux-openclaw-service.sh $PREFIX/var/service/openclaw/run
chmod +x $PREFIX/var/service/openclaw/run

echo -e "${GREEN}Step 9: Creating OpenClaw configuration...${NC}"
# Copy optimized configuration
if [ ! -f ~/.openclaw/openclaw.json ]; then
    mkdir -p ~/.openclaw
    cp $(dirname "$0")/openclaw-termux.json ~/.openclaw/openclaw.json
    echo -e "${YELLOW}Configuration created at ~/.openclaw/openclaw.json${NC}"
    echo -e "${YELLOW}Please edit it to add your API keys and preferences${NC}"
fi

echo -e "${GREEN}Step 10: Setting up wake lock to prevent sleep...${NC}"
# Install Termux:API if not present (user must install from F-Droid)
if ! command -v termux-wake-lock &> /dev/null; then
    pkg install -y termux-api
    echo -e "${YELLOW}Note: You must also install Termux:API from F-Droid for wake locks to work${NC}"
fi

echo -e "${GREEN}Step 11: Creating startup scripts...${NC}"
# Create convenience scripts
cat > ~/openclaw-start.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Start OpenClaw service
sv-enable openclaw
sv up openclaw
termux-wake-lock
echo "OpenClaw service started"
EOF
chmod +x ~/openclaw-start.sh

cat > ~/openclaw-stop.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Stop OpenClaw service
sv down openclaw
sv-disable openclaw
termux-wake-unlock
echo "OpenClaw service stopped"
EOF
chmod +x ~/openclaw-stop.sh

cat > ~/openclaw-status.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# Check OpenClaw service status
sv status openclaw
echo ""
echo "OpenClaw process:"
ps aux | grep -i openclaw | grep -v grep
EOF
chmod +x ~/openclaw-status.sh

cat > ~/openclaw-logs.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
# View OpenClaw logs
tail -f ~/.openclaw/logs/gateway.log
EOF
chmod +x ~/openclaw-logs.sh

echo ""
echo -e "${GREEN}========================================"
echo "Installation Complete!"
echo -e "========================================${NC}"
echo ""
echo "Next steps:"
echo "1. Install Termux:Boot from F-Droid for auto-start on device boot"
echo "2. Install Termux:API from F-Droid for wake locks and notifications"
echo "3. Edit ~/.openclaw/openclaw.json to configure your API keys"
echo "4. Run: ~/openclaw-start.sh to start OpenClaw"
echo ""
echo "Useful commands:"
echo "  ~/openclaw-start.sh   - Start OpenClaw service"
echo "  ~/openclaw-stop.sh    - Stop OpenClaw service"
echo "  ~/openclaw-status.sh  - Check service status"
echo "  ~/openclaw-logs.sh    - View live logs"
echo ""
echo "To enable auto-start on boot:"
echo "  mkdir -p ~/.termux/boot"
echo "  ln -s ~/openclaw-start.sh ~/.termux/boot/start-openclaw.sh"
echo ""
echo -e "${YELLOW}IMPORTANT: Configure your OpenClaw settings in ~/.openclaw/openclaw.json${NC}"
echo -e "${YELLOW}before starting the service!${NC}"

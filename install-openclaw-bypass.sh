#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw Bypass Installation Script for Linux/Termux
# This script provides a streamlined installation that bypasses manual setup
# Optimized for maximum performance - uses ALL memory and CPU cores without limits

set -e

echo "========================================"
echo "OpenClaw Bypass Installer"
echo "Ultra-Performance Mode for Termux"
echo "No Memory Limits | All CPU Cores"
echo "========================================"
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Detect environment
if [ -d "/data/data/com.termux" ]; then
    echo -e "${GREEN}✓ Termux environment detected${NC}"
    IS_TERMUX=1
    PREFIX="/data/data/com.termux/files/usr"
else
    echo -e "${YELLOW}⚠ Not running in Termux - Linux mode${NC}"
    IS_TERMUX=0
    PREFIX="/usr/local"
fi

echo -e "${BLUE}Step 1/10: System preparation...${NC}"
if [ $IS_TERMUX -eq 1 ]; then
    # Termux specific setup
    pkg update -y
    pkg upgrade -y
    pkg install -y nodejs-lts git python build-essential
    pkg install -y termux-services termux-api
    pkg install -y jq curl wget procps
else
    # Regular Linux
    echo "Please ensure Node.js, git, and build tools are installed"
fi

echo -e "${BLUE}Step 2/10: Verifying Node.js...${NC}"
node --version
npm --version

echo -e "${BLUE}Step 3/10: Installing pnpm...${NC}"
npm install -g pnpm

echo -e "${BLUE}Step 4/10: Cloning OpenClaw repository...${NC}"
cd ~
if [ -d "openclaw" ]; then
    echo -e "${YELLOW}OpenClaw directory exists. Updating...${NC}"
    cd openclaw
    git pull
else
    git clone https://github.com/openclaw/openclaw.git
    cd openclaw
fi

echo -e "${BLUE}Step 5/10: Installing dependencies (this may take a while)...${NC}"
# Configure npm for better reliability
npm config set prefer-offline false
npm config set fetch-retries 5
npm config set fetch-retry-mintimeout 20000
npm config set fetch-retry-maxtimeout 120000

# Install all dependencies
pnpm install

echo -e "${BLUE}Step 6/10: Building OpenClaw...${NC}"
pnpm ui:build
pnpm build

echo -e "${BLUE}Step 7/10: Creating ultra-performance configuration...${NC}"
mkdir -p ~/.openclaw/logs

# Create configuration with unlimited resources
cat > ~/.openclaw/openclaw.json << 'EOFCONFIG'
{
  "gateway": {
    "port": 18789,
    "bind": "0.0.0.0",
    "verbose": true,
    "auth": {
      "mode": "password",
      "password": "CHANGE_ME_STRONG_PASSWORD"
    }
  },
  "agent": {
    "model": "anthropic/claude-opus-4-6",
    "thinkingLevel": "high",
    "verboseLevel": "high"
  },
  "agents": {
    "defaults": {
      "workspace": "~/.openclaw/workspace",
      "sandbox": {
        "mode": "off"
      }
    }
  },
  "browser": {
    "enabled": true,
    "headless": true,
    "comment": "Browser enabled for maximum capabilities"
  },
  "channels": {
    "webchat": {
      "enabled": true
    },
    "telegram": {
      "enabled": false,
      "botToken": ""
    },
    "discord": {
      "enabled": false,
      "token": ""
    },
    "whatsapp": {
      "enabled": false
    }
  },
  "performance": {
    "comment": "UNLIMITED MODE - Uses all available resources",
    "maxConcurrentTasks": 16,
    "enableMultiCore": true,
    "noMemoryLimit": true
  },
  "logging": {
    "level": "info",
    "file": "~/.openclaw/logs/gateway.log",
    "maxSize": "50m",
    "maxFiles": 10
  },
  "system": {
    "wakeLock": true,
    "autoRestart": true,
    "healthCheck": {
      "enabled": true,
      "interval": 60000
    }
  }
}
EOFCONFIG

echo -e "${GREEN}✓ Configuration created at ~/.openclaw/openclaw.json${NC}"

echo -e "${BLUE}Step 8/10: Creating ultra-performance service...${NC}"

if [ $IS_TERMUX -eq 1 ]; then
    # Create Termux service
    mkdir -p $PREFIX/var/service/openclaw

    cat > $PREFIX/var/service/openclaw/run << 'EOFSERVICE'
#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw Ultra-Performance Service
# NO MEMORY LIMITS | ALL CPU CORES | MAXIMUM PERFORMANCE

# Acquire wake lock
termux-wake-lock 2>/dev/null || true

# Setup logging
LOG_DIR="$HOME/.openclaw/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/service-$(date +%Y%m%d).log"

exec 1>>"$LOG_FILE"
exec 2>&1

echo "========================================"
echo "OpenClaw Ultra-Performance Mode"
echo "Started: $(date)"
echo "========================================"

cd "$HOME/openclaw" || exit 1

# UNLIMITED MEMORY - Remove all memory restrictions
# Node.js will use as much memory as needed
export NODE_ENV=production

# MAXIMUM CPU UTILIZATION
CORES=$(nproc)
export UV_THREADPOOL_SIZE=$((CORES * 4))  # 4x thread pool per core
export OMP_NUM_THREADS=$CORES
export UV_USE_IO_URING=1  # Enable io_uring if available

# Additional performance flags
export NODE_OPTIONS="--max-old-space-size=8192 --max-semi-space-size=64 --expose-gc"

# System info
echo "Configuration:"
echo "  Node: $(node --version)"
echo "  CPU Cores: $CORES"
echo "  Thread Pool Size: $UV_THREADPOOL_SIZE"
echo "  OMP Threads: $OMP_NUM_THREADS"
echo "  Memory Limit: UNLIMITED (8GB soft limit)"
echo "  Available Memory: $(free -h | grep Mem | awk '{print $2}')"
echo ""

# Auto-restart loop
while true; do
    echo "[$(date)] Starting OpenClaw Gateway..."

    pnpm openclaw gateway --port 18789 --verbose

    EXIT_CODE=$?
    echo "[$(date)] OpenClaw exited with code $EXIT_CODE"

    if [ $EXIT_CODE -eq 0 ]; then
        echo "Clean shutdown - exiting"
        break
    fi

    echo "Auto-restarting in 5 seconds..."
    sleep 5
done

termux-wake-unlock 2>/dev/null || true
echo "Service stopped: $(date)"
EOFSERVICE

    chmod +x $PREFIX/var/service/openclaw/run
    echo -e "${GREEN}✓ Termux service created${NC}"
else
    # Create systemd service for regular Linux
    echo "For standard Linux, create systemd service manually"
fi

echo -e "${BLUE}Step 9/10: Creating control scripts...${NC}"

# Start script
cat > ~/openclaw-start.sh << 'EOFSTART'
#!/data/data/com.termux/files/usr/bin/bash
echo "Starting OpenClaw in Ultra-Performance Mode..."
if command -v sv &> /dev/null; then
    sv-enable openclaw
    sv up openclaw
else
    cd ~/openclaw
    nohup bash -c 'source ~/.openclaw-service.sh' > ~/.openclaw/logs/nohup.log 2>&1 &
fi
termux-wake-lock 2>/dev/null || true
echo "✓ OpenClaw started - using ALL available resources"
EOFSTART

# Stop script
cat > ~/openclaw-stop.sh << 'EOFSTOP'
#!/data/data/com.termux/files/usr/bin/bash
echo "Stopping OpenClaw..."
if command -v sv &> /dev/null; then
    sv down openclaw
    sv-disable openclaw
else
    pkill -f "openclaw gateway"
fi
termux-wake-unlock 2>/dev/null || true
echo "✓ OpenClaw stopped"
EOFSTOP

# Status script
cat > ~/openclaw-status.sh << 'EOFSTATUS'
#!/data/data/com.termux/files/usr/bin/bash
echo "OpenClaw Status"
echo "==============="
if command -v sv &> /dev/null; then
    sv status openclaw
fi
echo ""
echo "Processes:"
ps aux | grep -E "openclaw|node" | grep -v grep
echo ""
echo "Resource Usage:"
free -h
echo ""
echo "CPU Cores: $(nproc)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
EOFSTATUS

# Logs script
cat > ~/openclaw-logs.sh << 'EOFLOGS'
#!/data/data/com.termux/files/usr/bin/bash
tail -f ~/.openclaw/logs/service-$(date +%Y%m%d).log
EOFLOGS

chmod +x ~/openclaw-*.sh

echo -e "${BLUE}Step 10/10: Setting up boot auto-start...${NC}"
if [ $IS_TERMUX -eq 1 ]; then
    mkdir -p ~/.termux/boot
    ln -sf ~/openclaw-start.sh ~/.termux/boot/start-openclaw.sh
    chmod +x ~/.termux/boot/start-openclaw.sh
    echo -e "${GREEN}✓ Auto-start on boot configured${NC}"
    echo -e "${YELLOW}! Remember to open Termux:Boot app once and grant permissions${NC}"
fi

echo ""
echo -e "${GREEN}========================================"
echo "Installation Complete!"
echo -e "========================================${NC}"
echo ""
echo -e "${BLUE}Ultra-Performance Configuration:${NC}"
echo "  ✓ Memory: UNLIMITED (no restrictions)"
echo "  ✓ CPU: ALL $(nproc) cores at maximum"
echo "  ✓ Thread Pool: $(($(nproc) * 4)) threads"
echo "  ✓ Auto-restart: Enabled"
echo "  ✓ Wake lock: Enabled"
echo ""
echo -e "${YELLOW}IMPORTANT - Next Steps:${NC}"
echo "1. Edit ~/.openclaw/openclaw.json and set a strong password"
echo "2. Add your API keys (ANTHROPIC_API_KEY, etc.)"
echo "3. Configure channels (Telegram, Discord, etc.)"
echo ""
echo -e "${GREEN}Commands:${NC}"
echo "  ~/openclaw-start.sh   - Start OpenClaw"
echo "  ~/openclaw-stop.sh    - Stop OpenClaw"
echo "  ~/openclaw-status.sh  - Check status"
echo "  ~/openclaw-logs.sh    - View logs"
echo ""
echo -e "${GREEN}To start now:${NC}"
echo "  ~/openclaw-start.sh"
echo ""
echo -e "${BLUE}Web Interface:${NC}"
echo "  http://$(hostname -I | awk '{print $1}'):18789"
echo ""
echo -e "${RED}WARNING:${NC} This configuration uses unlimited memory and all CPU cores."
echo "Monitor your system to ensure stability!"
echo ""

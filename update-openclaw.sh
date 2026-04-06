#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw Update Script for Termux

set -e

echo "========================================"
echo "OpenClaw Update Script"
echo "========================================"

# Check if OpenClaw is running
if pgrep -f "openclaw gateway" > /dev/null; then
    echo "Stopping OpenClaw service..."
    ~/openclaw-stop.sh
    RESTART=true
else
    RESTART=false
fi

echo "Updating OpenClaw repository..."
cd ~/openclaw

# Stash any local changes
git stash

# Pull latest changes
git pull origin main

# Restore stashed changes if any
git stash pop 2>/dev/null || true

echo "Installing dependencies..."
pnpm install

echo "Building UI..."
pnpm ui:build

echo "Building OpenClaw..."
pnpm build

echo "Checking for configuration updates..."
if [ -f ~/luna/openclaw-termux.json ]; then
    echo "New configuration template available at ~/luna/openclaw-termux.json"
    echo "Compare with your current config: ~/.openclaw/openclaw.json"
fi

echo "Running OpenClaw doctor..."
cd ~/openclaw
pnpm openclaw doctor || true

if [ "$RESTART" = true ]; then
    echo "Restarting OpenClaw service..."
    ~/openclaw-start.sh
    sleep 3
    ~/openclaw-status.sh
fi

echo ""
echo "========================================"
echo "Update Complete!"
echo "========================================"
echo ""
echo "Current version:"
cd ~/openclaw
pnpm openclaw --version
echo ""
echo "If service is not running, start it with:"
echo "  ~/openclaw-start.sh"

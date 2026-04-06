#!/data/data/com.termux/files/usr/bin/bash
# Auto-start script for Termux:Boot
# Place this in ~/.termux/boot/ directory

# Wait for system to stabilize
sleep 30

# Acquire wake lock immediately
termux-wake-lock

# Start OpenClaw service
source $PREFIX/var/service/openclaw/run &

# Send notification
termux-notification --title "OpenClaw" --content "Service started automatically" 2>/dev/null || true

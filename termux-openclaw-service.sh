#!/data/data/com.termux/files/usr/bin/bash
# OpenClaw Termux Service Runner
# Runs OpenClaw gateway in background with automatic restart

# Acquire wake lock to prevent device sleep
termux-wake-lock 2>/dev/null || true

# Set up logging
LOG_DIR="$HOME/.openclaw/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/service-$(date +%Y%m%d).log"

# Redirect output to log
exec 1>>"$LOG_FILE"
exec 2>&1

echo "========================================"
echo "OpenClaw Service Starting: $(date)"
echo "========================================"

# Change to OpenClaw directory
cd "$HOME/openclaw" || exit 1

# Set environment variables for optimization
export NODE_ENV=production
export UV_THREADPOOL_SIZE=8  # Increase thread pool size for better multi-core usage
export NODE_OPTIONS="--max-old-space-size=1024"  # Limit memory to 1GB for tablet

# Enable all CPU cores
export OMP_NUM_THREADS=$(nproc)

# Log system info
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "CPU cores: $(nproc)"
echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Starting OpenClaw Gateway..."

# Start OpenClaw with automatic restart on crash
while true; do
    echo "Starting OpenClaw Gateway at $(date)"

    # Run OpenClaw gateway
    # Using pnpm to run the gateway with verbose logging
    pnpm openclaw gateway --port 18789 --verbose

    EXIT_CODE=$?
    echo "OpenClaw exited with code $EXIT_CODE at $(date)"

    # If exit code is 0, it was a clean shutdown, don't restart
    if [ $EXIT_CODE -eq 0 ]; then
        echo "Clean shutdown detected, exiting service"
        break
    fi

    # Wait before restarting to prevent rapid restart loops
    echo "Restarting in 5 seconds..."
    sleep 5
done

# Release wake lock on exit
termux-wake-unlock 2>/dev/null || true

echo "OpenClaw Service Stopped: $(date)"

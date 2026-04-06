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

# Set environment variables for MAXIMUM optimization
export NODE_ENV=production

# UNLIMITED MODE - Use all available resources
CORES=$(nproc)
export UV_THREADPOOL_SIZE=$((CORES * 4))  # 4x thread pool per core for maximum parallelism
export OMP_NUM_THREADS=$CORES

# NO MEMORY LIMIT - Use all available memory without restrictions
# Soft limit at 8GB, but Node.js will use what it needs
export NODE_OPTIONS="--max-old-space-size=8192 --max-semi-space-size=64 --expose-gc"

# Enable advanced performance features
export UV_USE_IO_URING=1  # Use io_uring if available (Linux 5.1+)

# Log system info
echo "========================================"
echo "ULTRA-PERFORMANCE MODE"
echo "========================================"
echo "Node version: $(node --version)"
echo "NPM version: $(npm --version)"
echo "CPU cores: $(nproc)"
echo "Thread pool size: $UV_THREADPOOL_SIZE"
echo "OMP threads: $OMP_NUM_THREADS"
echo "Total Memory: $(free -h | grep Mem | awk '{print $2}')"
echo "Memory Limit: UNLIMITED (8GB soft limit)"
echo "========================================"
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

#!/data/data/com.termux/files/usr/bin/bash
# Health monitoring script for OpenClaw
# Run this periodically to check service health

echo "OpenClaw Health Check - $(date)"
echo "========================================"

# Check if service is running
echo "1. Service Status:"
if pgrep -f "openclaw gateway" > /dev/null; then
    echo "   ✓ OpenClaw gateway is running"
    PID=$(pgrep -f "openclaw gateway")
    echo "   PID: $PID"
else
    echo "   ✗ OpenClaw gateway is NOT running"
fi

# Check wake lock
echo ""
echo "2. Wake Lock Status:"
if pgrep -f "termux-wake-lock" > /dev/null; then
    echo "   ✓ Wake lock is active"
else
    echo "   ✗ Wake lock is NOT active"
    echo "   Running: termux-wake-lock"
    termux-wake-lock
fi

# Check resource usage
echo ""
echo "3. Resource Usage:"
if pgrep -f "openclaw gateway" > /dev/null; then
    PID=$(pgrep -f "openclaw gateway")
    CPU=$(ps -p $PID -o %cpu | tail -1)
    MEM=$(ps -p $PID -o %mem | tail -1)
    RSS=$(ps -p $PID -o rss | tail -1)
    echo "   CPU: ${CPU}%"
    echo "   Memory: ${MEM}%"
    echo "   RSS: $((RSS / 1024)) MB"
fi

# Check system resources
echo ""
echo "4. System Resources:"
echo "   CPU Cores: $(nproc)"
echo "   Memory: $(free -h | grep Mem | awk '{print $3 " / " $2}')"
echo "   Disk: $(df -h $HOME | tail -1 | awk '{print $3 " / " $2 " (" $5 " used)"}')"

# Check network
echo ""
echo "5. Network Status:"
if nc -z -w 2 localhost 18789 2>/dev/null; then
    echo "   ✓ Gateway port 18789 is accessible"
else
    echo "   ✗ Gateway port 18789 is NOT accessible"
fi

# Check logs
echo ""
echo "6. Recent Logs (last 5 lines):"
if [ -f ~/.openclaw/logs/service-$(date +%Y%m%d).log ]; then
    tail -5 ~/.openclaw/logs/service-$(date +%Y%m%d).log
else
    echo "   No logs found for today"
fi

# Check for errors
echo ""
echo "7. Recent Errors:"
if [ -f ~/.openclaw/logs/service-$(date +%Y%m%d).log ]; then
    ERROR_COUNT=$(grep -i "error" ~/.openclaw/logs/service-$(date +%Y%m%d).log | wc -l)
    if [ $ERROR_COUNT -gt 0 ]; then
        echo "   ⚠ Found $ERROR_COUNT errors in today's logs"
        echo "   Last error:"
        grep -i "error" ~/.openclaw/logs/service-$(date +%Y%m%d).log | tail -1
    else
        echo "   ✓ No errors found in today's logs"
    fi
fi

echo ""
echo "========================================"
echo "Health check complete"

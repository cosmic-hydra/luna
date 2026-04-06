# Performance Tuning Guide for Samsung S6 Lite

## Hardware Specifications

- **CPU**: Qualcomm Snapdragon 720G (Octa-core)
  - 2x Kryo 465 Gold (2.3 GHz)
  - 6x Kryo 465 Silver (1.8 GHz)
- **RAM**: 4GB
- **Architecture**: ARM64 (aarch64)

## Optimization Levels

### Level 1: Basic (Default Configuration)

**Best for**: General usage, multiple channels enabled

```json
{
  "performance": {
    "maxConcurrentTasks": 4,
    "enableMultiCore": true
  },
  "agent": {
    "thinkingLevel": "medium"
  }
}
```

**Service configuration** (`termux-openclaw-service.sh`):
```bash
export NODE_OPTIONS="--max-old-space-size=1024"
export UV_THREADPOOL_SIZE=8
```

**Expected Performance**:
- Memory: ~600-800MB
- CPU: 30-50% average
- Response time: 2-5 seconds

---

### Level 2: High Performance

**Best for**: Heavy workloads, browser enabled, multiple concurrent requests

```json
{
  "performance": {
    "maxConcurrentTasks": 6,
    "enableMultiCore": true,
    "maxMemoryMB": 1536
  },
  "browser": {
    "enabled": true,
    "headless": true
  },
  "agent": {
    "thinkingLevel": "high"
  }
}
```

**Service configuration**:
```bash
export NODE_OPTIONS="--max-old-space-size=1536 --optimize-for-size"
export UV_THREADPOOL_SIZE=12
export OMP_NUM_THREADS=8
```

**Expected Performance**:
- Memory: ~1-1.5GB
- CPU: 50-70% average
- Response time: 1-3 seconds

**Warning**: Monitor memory usage. May cause issues if other apps are running.

---

### Level 3: Maximum Efficiency (Battery Saver)

**Best for**: Long-running 24/7 operation, minimal resource usage

```json
{
  "performance": {
    "maxConcurrentTasks": 2,
    "enableMultiCore": false,
    "maxMemoryMB": 512
  },
  "browser": {
    "enabled": false
  },
  "agent": {
    "thinkingLevel": "low"
  },
  "channels": {
    "comment": "Enable only channels you actively use",
    "telegram": { "enabled": true },
    "webchat": { "enabled": true },
    "discord": { "enabled": false },
    "whatsapp": { "enabled": false }
  },
  "logging": {
    "level": "warn",
    "maxFiles": 3
  }
}
```

**Service configuration**:
```bash
export NODE_OPTIONS="--max-old-space-size=512 --optimize-for-size --gc-interval=100"
export UV_THREADPOOL_SIZE=4
```

**Expected Performance**:
- Memory: ~300-500MB
- CPU: 15-30% average
- Response time: 3-8 seconds
- Battery impact: Minimal

---

## CPU Core Utilization

### Understanding Snapdragon 720G

The CPU uses big.LITTLE architecture:
- **Big cores** (2x @ 2.3GHz): Performance-focused
- **Little cores** (6x @ 1.8GHz): Efficiency-focused

### CPU Affinity Optimization

For intensive tasks, pin to big cores:

```bash
# Add to termux-openclaw-service.sh
taskset -c 0,1 pnpm openclaw gateway --port 18789 --verbose
```

For background operation, use all cores (default):
```bash
# Current default - uses all cores
pnpm openclaw gateway --port 18789 --verbose
```

### Thread Pool Sizing

**Conservative** (low resource):
```bash
export UV_THREADPOOL_SIZE=4
```

**Balanced** (default):
```bash
export UV_THREADPOOL_SIZE=8
```

**Aggressive** (high performance):
```bash
export UV_THREADPOOL_SIZE=16
```

---

## Memory Management

### Node.js Heap Configuration

**Minimum** (512MB):
```bash
export NODE_OPTIONS="--max-old-space-size=512 --optimize-for-size"
```

**Recommended** (1GB):
```bash
export NODE_OPTIONS="--max-old-space-size=1024"
```

**Maximum** (1.5GB - use with caution):
```bash
export NODE_OPTIONS="--max-old-space-size=1536"
```

### Garbage Collection Tuning

**Aggressive GC** (lower memory, higher CPU):
```bash
export NODE_OPTIONS="--max-old-space-size=1024 --gc-interval=100"
```

**Lazy GC** (higher memory, lower CPU):
```bash
export NODE_OPTIONS="--max-old-space-size=1024 --gc-interval=500"
```

**Incremental GC** (balanced):
```bash
export NODE_OPTIONS="--max-old-space-size=1024 --incremental-marking"
```

### Memory Monitoring

Add to service script:
```bash
# Log memory every hour
while true; do
    MEM=$(ps -p $PID -o rss= | awk '{print $1/1024 "MB"}')
    echo "[$(date)] Memory: $MEM" >> ~/.openclaw/logs/memory.log
    sleep 3600
done &
```

---

## Network Optimization

### Connection Pooling

For multiple channels, optimize connections:

```json
{
  "advanced": {
    "network": {
      "keepAlive": true,
      "timeout": 30000,
      "maxSockets": 50,
      "maxFreeSockets": 10
    }
  }
}
```

### WiFi Power Management

Disable WiFi sleep:
```bash
# In Termux
termux-wifi-connectioninfo
# If WiFi keeps disconnecting, disable power saving in Android settings
```

Android Settings:
- WiFi → Advanced → Keep WiFi on during sleep → Always

---

## Storage Optimization

### Log Rotation

**Aggressive rotation** (saves space):
```json
{
  "logging": {
    "maxSize": "5m",
    "maxFiles": 3
  }
}
```

**Standard rotation**:
```json
{
  "logging": {
    "maxSize": "10m",
    "maxFiles": 5
  }
}
```

### Automatic Cleanup

Add to crontab:
```bash
crontab -e

# Daily cleanup at 3 AM
0 3 * * * find ~/.openclaw/logs -name "*.log" -mtime +7 -delete
0 3 * * * find ~/.openclaw/workspace -name "*.tmp" -delete
0 3 * * * ~/openclaw-stop.sh && sleep 5 && ~/openclaw-start.sh
```

---

## Battery Optimization

### Power Profile

**Maximum Performance**:
```bash
# Set CPU governor to performance (requires root)
# Not recommended for 24/7 operation
```

**Balanced** (recommended):
```bash
# Default Android governor (schedutil/interactive)
# No changes needed
```

**Power Saver**:
- Reduce `maxConcurrentTasks` to 2
- Disable unused channels
- Use `thinkingLevel: "low"`
- Increase polling intervals

### Wake Lock Strategy

**Always-on** (default):
```bash
termux-wake-lock
```

**Partial wake lock** (screen can turn off):
```bash
# Default behavior - CPU stays active, screen can sleep
```

**Smart wake lock** (release during idle):
```bash
# Custom implementation in service script
while true; do
    if [ "$ACTIVE_REQUESTS" -gt 0 ]; then
        termux-wake-lock
    else
        termux-wake-unlock
    fi
    sleep 60
done
```

---

## Channel-Specific Optimizations

### Telegram

**High volume**:
```json
{
  "channels": {
    "telegram": {
      "polling": false,
      "webhookUrl": "https://your-domain/telegram-webhook",
      "maxConnections": 10
    }
  }
}
```

**Low volume**:
```json
{
  "channels": {
    "telegram": {
      "polling": true,
      "pollingInterval": 3000
    }
  }
}
```

### WhatsApp

**Reduce memory**:
```json
{
  "channels": {
    "whatsapp": {
      "maxMediaSize": "5mb",
      "autoDownloadMedia": false
    }
  }
}
```

### Discord

**Large servers**:
```json
{
  "channels": {
    "discord": {
      "intents": ["GUILDS", "GUILD_MESSAGES"],
      "cache": {
        "messages": 50,
        "users": 100
      }
    }
  }
}
```

---

## Performance Monitoring

### Real-time Monitoring

Create monitoring script:
```bash
#!/data/data/com.termux/files/usr/bin/bash
# monitor-performance.sh

while true; do
    clear
    echo "OpenClaw Performance Monitor - $(date)"
    echo "========================================"

    PID=$(pgrep -f "openclaw gateway")
    if [ ! -z "$PID" ]; then
        echo "CPU: $(ps -p $PID -o %cpu | tail -1)%"
        echo "Memory: $(ps -p $PID -o %mem | tail -1)%"
        echo "RSS: $(($(ps -p $PID -o rss | tail -1) / 1024))MB"
        echo ""
        echo "System:"
        echo "$(free -h | grep Mem)"
        echo ""
        echo "Network:"
        netstat -an | grep 18789
    else
        echo "OpenClaw not running"
    fi

    sleep 5
done
```

### Logging Performance Metrics

Add to service script:
```bash
# Performance logging
log_performance() {
    PID=$(pgrep -f "openclaw gateway")
    CPU=$(ps -p $PID -o %cpu | tail -1)
    MEM=$(ps -p $PID -o %mem | tail -1)
    RSS=$(($(ps -p $PID -o rss | tail -1) / 1024))
    echo "[$(date)] CPU: ${CPU}% MEM: ${MEM}% RSS: ${RSS}MB" >> ~/.openclaw/logs/performance.log
}

# Run every 5 minutes
while true; do
    log_performance
    sleep 300
done &
```

---

## Benchmarking

### Test Response Time

```bash
# Simple benchmark
cd ~/openclaw
time pnpm openclaw agent --message "Hello, what's 2+2?"
```

### Load Testing

```bash
# Send multiple requests
for i in {1..10}; do
    pnpm openclaw agent --message "Test $i" &
done
wait
```

### Memory Leak Detection

```bash
# Monitor memory over time
while true; do
    PID=$(pgrep -f "openclaw gateway")
    RSS=$(($(ps -p $PID -o rss | tail -1) / 1024))
    echo "$(date +%s) $RSS" >> ~/.openclaw/logs/mem-track.log
    sleep 60
done
```

Plot results:
```bash
# View memory trend
awk '{print $1, $2}' ~/.openclaw/logs/mem-track.log | tail -100
```

---

## Recommended Configurations by Use Case

### 1. Personal Assistant (Light Usage)

```json
{
  "performance": { "maxConcurrentTasks": 2 },
  "agent": { "thinkingLevel": "medium" },
  "channels": {
    "telegram": { "enabled": true },
    "webchat": { "enabled": true }
  },
  "browser": { "enabled": false }
}
```

Memory: ~400-600MB | CPU: 20-40%

### 2. Multi-Channel Bot (Medium Usage)

```json
{
  "performance": { "maxConcurrentTasks": 4 },
  "agent": { "thinkingLevel": "medium" },
  "channels": {
    "telegram": { "enabled": true },
    "discord": { "enabled": true },
    "whatsapp": { "enabled": true },
    "webchat": { "enabled": true }
  },
  "browser": { "enabled": false }
}
```

Memory: ~700-1000MB | CPU: 40-60%

### 3. Power User (Heavy Usage)

```json
{
  "performance": { "maxConcurrentTasks": 6 },
  "agent": { "thinkingLevel": "high" },
  "channels": {
    "telegram": { "enabled": true },
    "discord": { "enabled": true },
    "whatsapp": { "enabled": true },
    "slack": { "enabled": true },
    "webchat": { "enabled": true }
  },
  "browser": { "enabled": true },
  "skills": { "enabled": true, "autoInstall": true }
}
```

Memory: ~1200-1600MB | CPU: 60-80%

---

## Troubleshooting Performance Issues

### High CPU Usage

1. Check concurrent tasks:
   ```bash
   ps aux | grep openclaw
   ```

2. Reduce task limit:
   ```json
   { "performance": { "maxConcurrentTasks": 2 } }
   ```

3. Profile CPU:
   ```bash
   top -p $(pgrep -f "openclaw gateway")
   ```

### High Memory Usage

1. Check Node.js heap:
   ```bash
   node --expose-gc --inspect-brk
   ```

2. Reduce memory limit:
   ```bash
   export NODE_OPTIONS="--max-old-space-size=512"
   ```

3. Enable aggressive GC:
   ```bash
   export NODE_OPTIONS="--gc-interval=100"
   ```

### Slow Response Times

1. Check network latency:
   ```bash
   ping -c 10 api.anthropic.com
   ```

2. Reduce thinking level:
   ```json
   { "agent": { "thinkingLevel": "low" } }
   ```

3. Disable unused features:
   ```json
   { "browser": { "enabled": false } }
   ```

---

## Advanced Tweaks

### V8 Engine Tuning

```bash
export NODE_OPTIONS="
  --max-old-space-size=1024
  --optimize-for-size
  --gc-interval=100
  --initial-old-space-size=512
  --expose-gc
"
```

### Process Priority

```bash
# Lower priority for background operation
renice +10 $(pgrep -f "openclaw gateway")
```

### I/O Scheduling

```bash
# Best-effort I/O (requires root)
ionice -c 3 -p $(pgrep -f "openclaw gateway")
```

---

## Performance Checklist

- [ ] Disabled battery optimization for Termux
- [ ] Configured appropriate memory limits
- [ ] Set optimal concurrent task count
- [ ] Enabled only required channels
- [ ] Configured log rotation
- [ ] Set up wake lock
- [ ] Disabled unused features (browser if not needed)
- [ ] Optimized WiFi settings
- [ ] Configured appropriate thinking level
- [ ] Set up performance monitoring
- [ ] Tested response times
- [ ] Verified 24/7 stability

---

**Recommended starting point for Samsung S6 Lite**:
- `maxConcurrentTasks`: 4
- `NODE_OPTIONS`: `--max-old-space-size=1024`
- `UV_THREADPOOL_SIZE`: 8
- `thinkingLevel`: "medium"
- Enable only channels you use
- Browser: disabled (enable only if needed)

Monitor for 24 hours and adjust based on observed performance.

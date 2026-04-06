# OpenClaw Bypass Installation for Linux/Termux

## 🚀 Ultra-Performance Mode - No Limits!

This bypass installer provides a streamlined, one-command installation of OpenClaw with **unlimited memory** and **maximum CPU utilization** for Linux and Termux environments.

## Key Features

- ✅ **No Memory Limits**: Uses all available system memory (8GB soft limit)
- ✅ **Maximum CPU Utilization**: Uses ALL CPU cores with 4x thread pool multiplier
- ✅ **Automated Installation**: Single command to install everything
- ✅ **Termux Optimized**: Specifically designed for Android/Termux
- ✅ **24/7 Operation**: Auto-restart, wake locks, and crash recovery
- ✅ **No Manual Steps**: Bypasses all manual configuration

## Quick Start

### One-Command Installation

```bash
# Clone the repository
git clone https://github.com/cosmic-hydra/luna.git
cd luna

# Run the bypass installer
./install-openclaw-bypass.sh
```

That's it! The script handles everything automatically.

## What Gets Installed

1. **System Packages**: Node.js, Git, Build tools, Termux services
2. **OpenClaw**: Latest version from GitHub
3. **Ultra-Performance Configuration**: Optimized for maximum resource usage
4. **Service Runner**: Background service with auto-restart
5. **Control Scripts**: Easy start/stop/status commands
6. **Boot Auto-Start**: Automatically starts on device boot

## Performance Configuration

### Memory Settings

```bash
# NO MEMORY LIMIT - Uses what it needs
NODE_OPTIONS="--max-old-space-size=8192 --max-semi-space-size=64 --expose-gc"
```

- **8GB soft limit**: Prevents out-of-memory crashes
- **Garbage collection exposed**: For manual optimization if needed
- **Semi-space optimization**: Faster garbage collection

### CPU Settings

```bash
# Uses ALL CPU cores
CORES=$(nproc)
UV_THREADPOOL_SIZE=$((CORES * 4))  # 4x multiplier
OMP_NUM_THREADS=$CORES
UV_USE_IO_URING=1  # Advanced I/O on Linux 5.1+
```

- **Thread pool**: 4 threads per CPU core
- **Multi-threaded operations**: All cores utilized
- **io_uring**: Modern async I/O (Linux 5.1+)

### Example Performance on Different Devices

#### Samsung S6 Lite (8 cores)
- Thread Pool: 32 threads
- Concurrent Tasks: 16
- Memory: Unlimited (up to available)

#### Desktop Linux (16 cores)
- Thread Pool: 64 threads
- Concurrent Tasks: 16
- Memory: Unlimited (up to available)

## Usage

### Start OpenClaw

```bash
~/openclaw-start.sh
```

### Stop OpenClaw

```bash
~/openclaw-stop.sh
```

### Check Status

```bash
~/openclaw-status.sh
```

Output includes:
- Service status
- Running processes
- Memory usage
- CPU load
- Number of cores

### View Logs

```bash
~/openclaw-logs.sh
```

Or view specific date:
```bash
cat ~/.openclaw/logs/service-$(date +%Y%m%d).log
```

## Configuration

The ultra-performance configuration is automatically created at:
```
~/.openclaw/openclaw.json
```

### Important Settings to Customize

1. **Password** (REQUIRED):
```json
{
  "gateway": {
    "auth": {
      "password": "CHANGE_ME_STRONG_PASSWORD"
    }
  }
}
```

2. **API Keys**:
```bash
export ANTHROPIC_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"
```

Or add to `~/.bashrc` for persistence.

3. **Enable Channels**:
```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "your-bot-token"
    }
  }
}
```

## Ultra-Performance Features

### Concurrent Task Processing

Default configuration allows **16 concurrent tasks**:

```json
{
  "performance": {
    "maxConcurrentTasks": 16,
    "enableMultiCore": true,
    "noMemoryLimit": true
  }
}
```

Adjust based on your needs:
- Light usage: 4-8 tasks
- Medium usage: 8-12 tasks
- Heavy usage: 16+ tasks

### Browser Automation

Enabled by default with optimized settings:

```json
{
  "browser": {
    "enabled": true,
    "headless": true,
    "launchOptions": {
      "args": [
        "--disable-dev-shm-usage",
        "--no-sandbox"
      ]
    }
  }
}
```

## Auto-Start on Boot

### Termux

Automatically configured during installation:

```bash
mkdir -p ~/.termux/boot
# Link is created automatically
```

**Important**:
1. Install [Termux:Boot](https://f-droid.org/packages/com.termux.boot/) from F-Droid
2. Open the app once
3. Grant all permissions
4. Reboot to test

### Regular Linux (systemd)

Create a systemd service:

```bash
sudo tee /etc/systemd/system/openclaw.service << EOF
[Unit]
Description=OpenClaw Ultra-Performance Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=/home/$USER/openclaw
ExecStart=/home/$USER/openclaw-start.sh
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable openclaw
sudo systemctl start openclaw
```

## Monitoring Performance

### Real-Time Monitor

```bash
~/openclaw-status.sh
```

### Manual Monitoring

```bash
# CPU usage
top -p $(pgrep -f "openclaw gateway")

# Memory usage
ps aux | grep openclaw

# Detailed system info
free -h
nproc
uptime
```

### Log Performance Metrics

Performance metrics are automatically logged to:
```
~/.openclaw/logs/performance.log
```

## Troubleshooting

### Out of Memory Errors

Even with unlimited settings, the device has physical limits:

1. **Reduce concurrent tasks**:
```json
{ "performance": { "maxConcurrentTasks": 8 } }
```

2. **Disable browser**:
```json
{ "browser": { "enabled": false } }
```

3. **Add swap space** (Termux):
```bash
# Create 2GB swap file
dd if=/dev/zero of=~/swapfile bs=1M count=2048
chmod 600 ~/swapfile
mkswap ~/swapfile
swapon ~/swapfile
```

### High CPU Usage

This is expected! The configuration uses all cores. To reduce:

1. **Lower thread pool**:
```bash
# Edit service script
export UV_THREADPOOL_SIZE=8  # Instead of auto
```

2. **Reduce concurrent tasks**:
```json
{ "performance": { "maxConcurrentTasks": 4 } }
```

### Service Won't Start

1. **Check logs**:
```bash
cat ~/.openclaw/logs/service-$(date +%Y%m%d).log
```

2. **Verify Node.js**:
```bash
node --version  # Should be 18+
```

3. **Rebuild OpenClaw**:
```bash
cd ~/openclaw
pnpm install
pnpm build
```

### Battery Drain (Termux)

For 24/7 operation on battery:

1. **Keep device plugged in** (recommended)

2. **Optimize battery settings**:
   - Settings → Apps → Termux → Battery → Unrestricted
   - Settings → Battery → Power saving off
   - Settings → WiFi → Keep WiFi on during sleep

3. **Reduce performance**:
   - Use `openclaw-termux.json` instead of `openclaw-ultra.json`
   - Lower concurrent tasks
   - Disable browser

## Comparison: Standard vs Bypass Installation

| Feature | Standard Install | Bypass Install |
|---------|-----------------|----------------|
| Memory Limit | 1GB | Unlimited (8GB) |
| Thread Pool | 8 threads | 4x CPU cores |
| CPU Cores | All | All (optimized) |
| Concurrent Tasks | 4 | 16 |
| Installation Steps | ~10 manual | 1 command |
| Configuration | Manual | Automated |
| Browser | Disabled | Enabled |

## Advanced Tuning

### For Maximum Performance

Edit `~/.openclaw/openclaw.json`:

```json
{
  "performance": {
    "maxConcurrentTasks": 32,
    "enableMultiCore": true,
    "noMemoryLimit": true
  },
  "agent": {
    "thinkingLevel": "high"
  },
  "browser": {
    "enabled": true
  }
}
```

### For Stability

```json
{
  "performance": {
    "maxConcurrentTasks": 8,
    "enableMultiCore": true
  },
  "agent": {
    "thinkingLevel": "medium"
  },
  "browser": {
    "enabled": false
  }
}
```

## Security Considerations

1. **Change default password** immediately
2. **Use strong API keys**
3. **Enable firewall** for production:
```bash
# Termux doesn't have iptables by default
# For Linux:
sudo ufw allow 18789/tcp
sudo ufw enable
```

4. **Use VPN** for remote access (recommended):
   - Tailscale
   - WireGuard
   - OpenVPN

## Files Created

- `~/openclaw/` - OpenClaw installation
- `~/.openclaw/openclaw.json` - Configuration
- `~/.openclaw/logs/` - Log files
- `~/openclaw-start.sh` - Start script
- `~/openclaw-stop.sh` - Stop script
- `~/openclaw-status.sh` - Status script
- `~/openclaw-logs.sh` - Log viewer
- `~/.termux/boot/start-openclaw.sh` - Boot script (Termux)
- `/data/data/com.termux/files/usr/var/service/openclaw/run` - Service script (Termux)

## Uninstallation

```bash
# Stop service
~/openclaw-stop.sh

# Remove files
rm -rf ~/openclaw
rm -rf ~/.openclaw
rm ~/openclaw-*.sh
rm ~/.termux/boot/start-openclaw.sh

# Remove service (Termux)
rm -rf /data/data/com.termux/files/usr/var/service/openclaw
```

## Support

- OpenClaw Docs: https://docs.openclaw.ai
- OpenClaw Discord: https://discord.gg/clawd
- GitHub Issues: https://github.com/cosmic-hydra/luna/issues

## License

MIT License - See [LICENSE](LICENSE)

---

**Built for maximum performance on Linux and Android/Termux** 🚀⚡

# OpenClaw for Android Termux

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

> 24/7 OpenClaw AI Assistant deployment for Android devices via Termux
> Optimized for Samsung S6 Lite and similar Android tablets

## Overview

This repository provides a complete setup to run [OpenClaw](https://github.com/openclaw/openclaw) on Android devices using Termux. It's designed for 24/7 background operation without UI, with full multi-core CPU utilization and online connectivity.

### Features

- ✅ **24/7 Operation**: Runs continuously in the background
- ✅ **No UI Required**: Fully headless operation
- ✅ **Multi-Core Optimization**: Utilizes all available CPU cores
- ✅ **Auto-Start on Boot**: Automatically starts when device boots
- ✅ **Auto-Restart on Crash**: Built-in watchdog for reliability
- ✅ **Wake Lock Support**: Prevents device sleep during operation
- ✅ **Resource Optimized**: Tuned for Android tablet hardware
- ✅ **Online Connected**: Full API integration with OpenClaw services
- ✅ **Easy Installation**: One-command setup

## Requirements

### Hardware
- **Device**: Samsung S6 Lite or similar Android tablet
- **RAM**: 4GB minimum (recommended)
- **Storage**: 2GB free space minimum
- **CPU**: Multi-core processor (Snapdragon 720G or better)

### Software
- **Termux**: Latest version from [F-Droid](https://f-droid.org/packages/com.termux/)
- **Termux:Boot**: From [F-Droid](https://f-droid.org/packages/com.termux.boot/) (for auto-start)
- **Termux:API**: From [F-Droid](https://f-droid.org/packages/com.termux.api/) (for wake locks and notifications)
- **Android**: 7.0 or higher

## Installation

### 1. Install Required Termux Apps

Install these apps from F-Droid (NOT Google Play Store):
- [Termux](https://f-droid.org/packages/com.termux/)
- [Termux:Boot](https://f-droid.org/packages/com.termux.boot/)
- [Termux:API](https://f-droid.org/packages/com.termux.api/)

### 2. Clone and Run Installer

Open Termux and run:

```bash
# Clone this repository
git clone https://github.com/cosmic-hydra/luna.git
cd luna

# Make installer executable
chmod +x install-termux.sh

# Run installation
./install-termux.sh
```

The installer will:
- Update Termux packages
- Install Node.js 24 (LTS) and dependencies
- Clone and build OpenClaw
- Set up background services
- Create convenience scripts
- Configure auto-restart

### 3. Configure OpenClaw

Edit the configuration file:

```bash
nano ~/.openclaw/openclaw.json
```

**Important settings to configure:**
- Set a strong `gateway.auth.password`
- Add your AI model API keys (OpenAI, Anthropic, etc.)
- Enable desired channels (Telegram, Discord, WhatsApp, etc.)
- Configure authentication tokens

Example minimal configuration:

```json
{
  "gateway": {
    "port": 18789,
    "auth": {
      "mode": "password",
      "password": "your-strong-password-here"
    }
  },
  "agent": {
    "model": "anthropic/claude-opus-4-6"
  }
}
```

### 4. Set Your API Keys

Set environment variables or add to `~/.bashrc`:

```bash
export ANTHROPIC_API_KEY="your-key-here"
export OPENAI_API_KEY="your-key-here"
export TELEGRAM_BOT_TOKEN="your-token-here"  # if using Telegram
export DISCORD_BOT_TOKEN="your-token-here"   # if using Discord
```

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

### View Logs

```bash
~/openclaw-logs.sh
```

Or view specific date logs:
```bash
cat ~/.openclaw/logs/service-$(date +%Y%m%d).log
```

## Auto-Start on Device Boot

To enable automatic startup when your tablet boots:

```bash
# Create boot directory
mkdir -p ~/.termux/boot

# Link the boot script
ln -s ~/luna/start-openclaw-boot.sh ~/.termux/boot/start-openclaw.sh

# Make it executable
chmod +x ~/.termux/boot/start-openclaw.sh
```

**Important**:
1. Open Termux:Boot app at least once after installation
2. Grant necessary permissions
3. Reboot your device to test

## Accessing OpenClaw

### WebChat Interface

Access the web interface at:
```
http://your-tablet-ip:18789
```

To find your tablet's IP:
```bash
ifconfig wlan0 | grep inet
```

### Remote Access

For remote access from other devices on your network, ensure:
1. Your tablet is connected to WiFi
2. Port 18789 is accessible
3. You use the password configured in `openclaw.json`

### CLI Access

Use OpenClaw CLI directly in Termux:

```bash
cd ~/openclaw

# Send a message
pnpm openclaw message send --to "+1234567890" --message "Hello"

# Talk to assistant
pnpm openclaw agent --message "What can you help me with?"

# Check gateway status
pnpm openclaw doctor
```

## Optimization for Samsung S6 Lite

The configuration is optimized for Samsung S6 Lite specs:
- **CPU**: Snapdragon 720G (8 cores)
- **RAM**: 4GB
- **Thread Pool**: 8 threads
- **Memory Limit**: 1GB for Node.js
- **Concurrent Tasks**: 4 maximum

### Multi-Core Utilization

The service is configured to use all available CPU cores:
- `UV_THREADPOOL_SIZE=8`: Increases Node.js thread pool
- `OMP_NUM_THREADS=$(nproc)`: Uses all CPU cores
- Concurrent task processing enabled

## Battery Optimization

To ensure 24/7 operation:

1. **Disable Battery Optimization** for Termux:
   - Settings → Apps → Termux
   - Battery → Unrestricted

2. **Disable Doze Mode** for Termux:
   - Settings → Apps → Termux → Battery
   - Turn off battery optimization

3. **Keep WiFi On During Sleep**:
   - Settings → WiFi → Advanced
   - Keep WiFi on during sleep: Always

4. **Wake Lock**: Automatically acquired by the service

## Troubleshooting

### Service Won't Start

Check logs:
```bash
cat ~/.openclaw/logs/service-$(date +%Y%m%d).log
```

Verify Node.js:
```bash
node --version  # Should be 22.16+ or 24+
```

### Service Stops After Screen Lock

Ensure:
- Battery optimization is disabled
- Wake lock is acquired: `termux-wake-lock`
- Termux:API is installed

### Memory Issues

Reduce concurrent tasks in `~/.openclaw/openclaw.json`:
```json
{
  "performance": {
    "maxConcurrentTasks": 2
  }
}
```

### Can't Access Web Interface

Check if gateway is running:
```bash
~/openclaw-status.sh
```

Check firewall/network:
```bash
netstat -tlnp | grep 18789
```

### Auto-Start Not Working

Verify Termux:Boot:
1. Open Termux:Boot app
2. Grant all permissions
3. Check boot script exists: `ls ~/.termux/boot/`
4. Reboot device and check logs

## Advanced Configuration

### Enable Browser Automation

If you have sufficient resources (6GB+ RAM recommended):

```json
{
  "browser": {
    "enabled": true
  }
}
```

### Configure Channels

Enable additional messaging platforms:

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "your-bot-token"
    },
    "discord": {
      "enabled": true,
      "token": "your-discord-token"
    },
    "whatsapp": {
      "enabled": true
    }
  }
}
```

### Adjust Logging

```json
{
  "logging": {
    "level": "debug",
    "maxSize": "20m",
    "maxFiles": 10
  }
}
```

## Architecture

```
Android Tablet (Samsung S6 Lite)
    │
    └─── Termux
            │
            ├─── Node.js 24 LTS
            │       └─── OpenClaw Gateway (port 18789)
            │               ├─── WebChat Interface
            │               ├─── API Endpoints
            │               └─── Channel Integrations
            │                       ├─── Telegram
            │                       ├─── Discord
            │                       ├─── WhatsApp
            │                       └─── Others
            │
            ├─── Wake Lock (24/7 operation)
            ├─── Auto-restart Watchdog
            └─── Multi-core Task Distribution
```

## Performance Monitoring

Monitor resource usage:

```bash
# CPU usage
top -n 1 | grep node

# Memory usage
free -h

# Process info
ps aux | grep openclaw

# Network connections
netstat -tlnp | grep 18789
```

## Updating OpenClaw

To update to the latest version:

```bash
cd ~/openclaw
git pull
pnpm install
pnpm ui:build
pnpm build

# Restart service
~/openclaw-stop.sh
~/openclaw-start.sh
```

## Security Considerations

1. **Change Default Password**: Always set a strong password in `openclaw.json`
2. **Network Access**: Consider using VPN or Tailscale for remote access
3. **API Keys**: Keep API keys secure and never commit them to git
4. **Local Network Only**: By default, gateway binds to all interfaces (0.0.0.0)
5. **DM Pairing**: Enable pairing mode for unknown DMs (see OpenClaw security docs)

## Contributing

Issues and pull requests welcome! Please test on Android/Termux before submitting.

## License

MIT License - see [LICENSE](LICENSE) file

## Acknowledgments

- [OpenClaw](https://github.com/openclaw/openclaw) - The amazing AI assistant platform
- [Termux](https://termux.com/) - Terminal emulator for Android
- Samsung S6 Lite community for optimization tips

## Support

- OpenClaw Docs: https://docs.openclaw.ai
- OpenClaw Discord: https://discord.gg/clawd
- Termux Wiki: https://wiki.termux.com/

## Links

- [OpenClaw Repository](https://github.com/openclaw/openclaw)
- [OpenClaw Documentation](https://docs.openclaw.ai)
- [Termux F-Droid](https://f-droid.org/packages/com.termux/)
- [Termux:Boot](https://f-droid.org/packages/com.termux.boot/)
- [Termux:API](https://f-droid.org/packages/com.termux.api/)

---

**Built for 24/7 AI assistance on Android tablets** 🤖📱

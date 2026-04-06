# Quick Start Guide

## Installation (5 minutes)

1. **Install Termux apps** (from F-Droid, NOT Play Store):
   - Termux
   - Termux:Boot
   - Termux:API

2. **Open Termux and run**:
   ```bash
   pkg install git -y
   git clone https://github.com/cosmic-hydra/luna.git
   cd luna
   chmod +x install-termux.sh
   ./install-termux.sh
   ```

3. **Configure API keys**:
   ```bash
   nano ~/.openclaw/openclaw.json
   ```
   - Change the password
   - Add your Anthropic/OpenAI API key

4. **Start OpenClaw**:
   ```bash
   ~/openclaw-start.sh
   ```

5. **Access Web Interface**:
   - Find your IP: `ifconfig wlan0 | grep inet`
   - Open browser: `http://YOUR_IP:18789`
   - Login with your password

## Enable Auto-Start on Boot

```bash
mkdir -p ~/.termux/boot
ln -s ~/luna/start-openclaw-boot.sh ~/.termux/boot/start-openclaw.sh
chmod +x ~/.termux/boot/start-openclaw.sh
```

Open Termux:Boot app once, then reboot to test.

## Disable Battery Optimization

1. Go to: **Settings → Apps → Termux**
2. Tap **Battery**
3. Select **Unrestricted**

## Essential Commands

```bash
~/openclaw-start.sh      # Start service
~/openclaw-stop.sh       # Stop service
~/openclaw-status.sh     # Check status
~/openclaw-logs.sh       # View logs
./health-check.sh        # Health check
```

## Getting Your API Keys

### Anthropic (Claude)
1. Go to https://console.anthropic.com/
2. Create an account
3. Go to API Keys section
4. Create a new key
5. Add to `~/.openclaw/openclaw.json` or set env:
   ```bash
   export ANTHROPIC_API_KEY="your-key"
   ```

### OpenAI (GPT)
1. Go to https://platform.openai.com/
2. Create an account
3. Go to API Keys section
4. Create a new key
5. Add to config or set env:
   ```bash
   export OPENAI_API_KEY="your-key"
   ```

## Enable Telegram Bot

1. Talk to [@BotFather](https://t.me/botfather) on Telegram
2. Create a new bot with `/newbot`
3. Copy the token
4. Add to config:
   ```json
   {
     "channels": {
       "telegram": {
         "enabled": true,
         "botToken": "your-token-here"
       }
     }
   }
   ```
5. Restart: `~/openclaw-stop.sh && ~/openclaw-start.sh`

## Troubleshooting

**Service won't start?**
```bash
# Check logs
cat ~/.openclaw/logs/service-$(date +%Y%m%d).log

# Check Node version
node --version  # Should be 22+

# Reinstall
cd luna
./install-termux.sh
```

**Stops after screen lock?**
- Disable battery optimization (see above)
- Ensure wake lock: `termux-wake-lock`

**Can't access web interface?**
```bash
# Check if running
~/openclaw-status.sh

# Check port
netstat -tlnp | grep 18789
```

## Need Help?

- Full README: See [README.md](README.md)
- OpenClaw Docs: https://docs.openclaw.ai
- Discord: https://discord.gg/clawd

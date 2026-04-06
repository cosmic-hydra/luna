# Troubleshooting Guide

## Common Issues and Solutions

### Installation Issues

#### 1. "Package not found" errors during installation

**Problem**: Termux package manager can't find packages

**Solution**:
```bash
# Update package repositories
pkg update
pkg upgrade

# Clear package cache
pkg clean

# Try installation again
./install-termux.sh
```

#### 2. Node.js version too old

**Problem**: Need Node.js 22+ but older version installed

**Solution**:
```bash
# Install latest LTS
pkg install nodejs-lts

# Verify version
node --version
```

#### 3. Out of storage space

**Problem**: Not enough space for installation

**Solution**:
```bash
# Check storage
df -h $HOME

# Clean package cache
pkg clean

# Remove old logs
rm -rf ~/.openclaw/logs/*

# Check for large files
du -sh ~/openclaw/* | sort -h
```

---

### Service Issues

#### 4. Service won't start

**Problem**: OpenClaw service fails to start

**Diagnosis**:
```bash
# Check logs
cat ~/.openclaw/logs/service-$(date +%Y%m%d).log

# Try manual start
cd ~/openclaw
pnpm openclaw gateway --port 18789 --verbose
```

**Common Causes**:

a. **Port already in use**:
```bash
# Check if something is using port 18789
netstat -tlnp | grep 18789

# Kill existing process
kill -9 $(lsof -t -i:18789)
```

b. **Missing configuration**:
```bash
# Check if config exists
ls -la ~/.openclaw/openclaw.json

# Copy default if missing
cp ~/luna/openclaw-termux.json ~/.openclaw/openclaw.json
```

c. **Missing dependencies**:
```bash
cd ~/openclaw
pnpm install
pnpm build
```

#### 5. Service stops after a few minutes

**Problem**: Service runs then stops unexpectedly

**Solution**:

a. **Check battery optimization**:
- Settings → Apps → Termux → Battery → Unrestricted

b. **Ensure wake lock**:
```bash
termux-wake-lock
```

c. **Check for crashes in logs**:
```bash
grep -i "error\|crash\|exit" ~/.openclaw/logs/service-*.log
```

d. **Check memory**:
```bash
free -h
# If low memory, reduce concurrent tasks in config
```

#### 6. Service restarts repeatedly

**Problem**: Service keeps crashing and restarting

**Diagnosis**:
```bash
# Check for error patterns
grep -i "error" ~/.openclaw/logs/service-$(date +%Y%m%d).log | tail -20
```

**Solutions**:

a. **Memory issues**:
Edit `~/.openclaw/openclaw.json`:
```json
{
  "performance": {
    "maxConcurrentTasks": 2
  }
}
```

b. **API key issues**:
```bash
# Verify API keys are set
echo $ANTHROPIC_API_KEY
echo $OPENAI_API_KEY

# Or check in config file
grep -i "apikey\|token" ~/.openclaw/openclaw.json
```

---

### Network/Access Issues

#### 7. Can't access web interface

**Problem**: Browser can't connect to http://IP:18789

**Solutions**:

a. **Check service is running**:
```bash
~/openclaw-status.sh
```

b. **Find correct IP address**:
```bash
ifconfig wlan0 | grep "inet "
# Use the IP shown (e.g., 192.168.1.100)
```

c. **Check firewall**:
```bash
# Test local access first
curl http://localhost:18789

# If works locally but not remotely, might be network issue
```

d. **Verify port binding**:
```bash
netstat -tlnp | grep 18789
# Should show 0.0.0.0:18789 (all interfaces)
```

e. **Check password**:
- Make sure you're using the password from `~/.openclaw/openclaw.json`

#### 8. "Connection refused" errors

**Problem**: Network connections fail

**Solutions**:

a. **Check WiFi**:
```bash
# Verify WiFi is connected
ifconfig wlan0
ping -c 3 8.8.8.8
```

b. **Restart service**:
```bash
~/openclaw-stop.sh
sleep 2
~/openclaw-start.sh
```

c. **Check gateway configuration**:
```json
{
  "gateway": {
    "bind": "0.0.0.0",  // Should be this, not "localhost"
    "port": 18789
  }
}
```

---

### Auto-Start Issues

#### 9. Doesn't start on boot

**Problem**: Service doesn't auto-start when tablet boots

**Solutions**:

a. **Verify Termux:Boot installed**:
- Must be from F-Droid, not Play Store
- Open the app at least once

b. **Check boot script**:
```bash
ls -la ~/.termux/boot/
# Should show start-openclaw.sh

# Make sure it's executable
chmod +x ~/.termux/boot/start-openclaw.sh
```

c. **Test boot script manually**:
```bash
~/.termux/boot/start-openclaw.sh
# Wait 30 seconds then check status
~/openclaw-status.sh
```

d. **Check Termux permissions**:
- Settings → Apps → Termux
- Ensure all permissions granted
- Especially "Run in background"

#### 10. Wake lock not working

**Problem**: Device sleeps and service stops

**Solutions**:

a. **Install Termux:API**:
```bash
pkg install termux-api
```
Also install Termux:API from F-Droid (the app)

b. **Manually acquire wake lock**:
```bash
termux-wake-lock
```

c. **Verify wake lock**:
```bash
termux-wake-lock-status
```

d. **Disable Doze mode for Termux**:
- Settings → Battery → Battery optimization
- Find Termux → Don't optimize

---

### Channel-Specific Issues

#### 11. Telegram bot not responding

**Problem**: Telegram bot doesn't reply

**Solutions**:

a. **Verify bot token**:
```bash
# Check token in config
grep -A 3 "telegram" ~/.openclaw/openclaw.json
```

b. **Test bot token**:
```bash
TOKEN="your-bot-token"
curl "https://api.telegram.org/bot${TOKEN}/getMe"
# Should return bot info
```

c. **Check logs for Telegram errors**:
```bash
grep -i "telegram" ~/.openclaw/logs/service-$(date +%Y%m%d).log
```

d. **Restart service**:
```bash
~/openclaw-stop.sh && ~/openclaw-start.sh
```

#### 12. WhatsApp won't connect

**Problem**: WhatsApp channel fails to pair

**Solutions**:

a. **Re-login**:
```bash
cd ~/openclaw
pnpm openclaw channels login --channel whatsapp
# Scan QR code
```

b. **Check credentials**:
```bash
ls -la ~/.openclaw/credentials/
# Should have WhatsApp session files
```

c. **Clear and re-pair**:
```bash
rm -rf ~/.openclaw/credentials/whatsapp*
cd ~/openclaw
pnpm openclaw channels login --channel whatsapp
```

---

### Performance Issues

#### 13. Slow response times

**Problem**: OpenClaw responds very slowly

**Solutions**:

a. **Check CPU usage**:
```bash
top -n 1
# If OpenClaw is using 100% CPU consistently, might be overloaded
```

b. **Reduce concurrent tasks**:
Edit `~/.openclaw/openclaw.json`:
```json
{
  "performance": {
    "maxConcurrentTasks": 2
  }
}
```

c. **Disable browser if enabled**:
```json
{
  "browser": {
    "enabled": false
  }
}
```

d. **Check memory**:
```bash
free -h
# If very low, close other apps
```

#### 14. High memory usage

**Problem**: OpenClaw using too much RAM

**Solutions**:

a. **Reduce Node.js memory limit**:
Edit `termux-openclaw-service.sh`:
```bash
export NODE_OPTIONS="--max-old-space-size=512"  # Reduce from 1024
```

b. **Restart service regularly**:
```bash
# Add to crontab for nightly restart
crontab -e
# Add: 0 3 * * * ~/openclaw-stop.sh && sleep 5 && ~/openclaw-start.sh
```

c. **Disable unused channels**:
```json
{
  "channels": {
    "whatsapp": { "enabled": false },
    "discord": { "enabled": false }
    // Only enable what you use
  }
}
```

---

### Update Issues

#### 15. Update fails

**Problem**: Update script fails or breaks installation

**Solutions**:

a. **Manual update**:
```bash
cd ~/openclaw
git fetch origin
git reset --hard origin/main
pnpm install
pnpm ui:build
pnpm build
```

b. **Fresh install** (preserves config):
```bash
# Backup config
cp ~/.openclaw/openclaw.json ~/openclaw-config-backup.json

# Remove OpenClaw
rm -rf ~/openclaw

# Clone fresh
cd ~
git clone https://github.com/openclaw/openclaw.git
cd openclaw
pnpm install
pnpm ui:build
pnpm build

# Restore config
cp ~/openclaw-config-backup.json ~/.openclaw/openclaw.json
```

---

### Data/Log Issues

#### 16. Logs growing too large

**Problem**: Log files filling up storage

**Solutions**:

a. **Reduce log retention**:
Edit `~/.openclaw/openclaw.json`:
```json
{
  "logging": {
    "maxSize": "5m",
    "maxFiles": 3
  }
}
```

b. **Manual cleanup**:
```bash
# Remove old logs
find ~/.openclaw/logs -name "*.log" -mtime +7 -delete

# Keep only today's service log
cd ~/.openclaw/logs
ls service-*.log | grep -v $(date +%Y%m%d) | xargs rm -f
```

c. **Reduce logging level**:
```json
{
  "logging": {
    "level": "warn"  // Changed from "info" or "debug"
  }
}
```

#### 17. Lost configuration

**Problem**: Configuration file missing or corrupted

**Solutions**:

a. **Restore from template**:
```bash
cp ~/luna/openclaw-termux.json ~/.openclaw/openclaw.json
nano ~/.openclaw/openclaw.json
# Re-enter your API keys and settings
```

b. **Check for backup**:
```bash
ls -la ~/.openclaw/*.json*
# Might have auto-backup files
```

---

## Diagnostic Commands

### Quick Health Check
```bash
./health-check.sh
```

### Detailed Diagnostics
```bash
# Service status
~/openclaw-status.sh

# System resources
free -h
df -h
nproc

# Network
ifconfig
netstat -tlnp | grep 18789

# Processes
ps aux | grep -i openclaw

# Recent logs
tail -50 ~/.openclaw/logs/service-$(date +%Y%m%d).log

# Error summary
grep -i "error" ~/.openclaw/logs/service-*.log | tail -20

# OpenClaw doctor
cd ~/openclaw
pnpm openclaw doctor
```

### Test API Connectivity
```bash
# Test Anthropic API
curl -H "x-api-key: $ANTHROPIC_API_KEY" https://api.anthropic.com/v1/messages

# Test OpenAI API
curl -H "Authorization: Bearer $OPENAI_API_KEY" https://api.openai.com/v1/models
```

---

## Getting Help

If none of these solutions work:

1. **Collect diagnostic info**:
```bash
# Run full diagnostics
./health-check.sh > ~/diagnostics.txt
cat ~/.openclaw/logs/service-$(date +%Y%m%d).log >> ~/diagnostics.txt
cd ~/openclaw && pnpm openclaw doctor >> ~/diagnostics.txt
```

2. **Check OpenClaw docs**:
   - https://docs.openclaw.ai
   - https://docs.openclaw.ai/help/faq

3. **Join Discord**:
   - https://discord.gg/clawd

4. **Check GitHub issues**:
   - https://github.com/openclaw/openclaw/issues
   - https://github.com/cosmic-hydra/luna/issues

5. **Create an issue** with:
   - Your diagnostics output
   - Device model (Samsung S6 Lite)
   - Android version
   - Termux version
   - Steps to reproduce
   - Error messages

---

## Prevention Tips

1. **Regular updates**:
   ```bash
   ~/luna/update-openclaw.sh
   ```

2. **Monitor health**:
   ```bash
   # Add to cron for daily health checks
   crontab -e
   # Add: 0 12 * * * ~/luna/health-check.sh >> ~/health-log.txt
   ```

3. **Backup configuration**:
   ```bash
   # Regular backups
   cp ~/.openclaw/openclaw.json ~/openclaw-config-$(date +%Y%m%d).json
   ```

4. **Keep storage clean**:
   ```bash
   # Weekly cleanup
   pkg clean
   find ~/.openclaw/logs -name "*.log" -mtime +7 -delete
   ```

5. **Monitor resources**:
   ```bash
   # Check periodically
   free -h
   df -h
   top -n 1 | grep node
   ```

# Project Files Overview

## Core Installation Files

### `install-termux.sh`
Main installation script that:
- Updates Termux packages
- Installs Node.js, Git, and dependencies
- Clones and builds OpenClaw
- Sets up background services
- Creates convenience scripts
- Configures auto-restart mechanisms

**Usage**: `./install-termux.sh`

### `termux-openclaw-service.sh`
Service runner script that:
- Acquires wake locks
- Starts OpenClaw gateway
- Implements auto-restart on crash
- Logs service activity
- Manages environment variables

**Location**: Installed to `$PREFIX/var/service/openclaw/run`

### `start-openclaw-boot.sh`
Boot script for Termux:Boot that:
- Waits for system stabilization
- Acquires wake lock
- Starts OpenClaw service automatically
- Sends notification on startup

**Usage**: Link to `~/.termux/boot/` directory

---

## Configuration Files

### `openclaw-termux.json`
Basic configuration optimized for Samsung S6 Lite:
- Gateway settings (port, auth)
- Agent configuration
- Channel settings (Telegram, Discord, WhatsApp, etc.)
- Performance tuning for 4GB RAM
- Logging configuration

**Location**: Copied to `~/.openclaw/openclaw.json`

### `openclaw-advanced.json`
Advanced configuration template with:
- All available options
- Detailed comments
- Performance tuning parameters
- Security settings
- Advanced features (cron, webhooks, skills)

**Usage**: Reference for advanced configuration

---

## Utility Scripts

### `openclaw-start.sh`
Starts OpenClaw service
- Enables service
- Acquires wake lock
- Shows status

**Location**: `~/openclaw-start.sh`

### `openclaw-stop.sh`
Stops OpenClaw service
- Disables service
- Releases wake lock
- Confirms shutdown

**Location**: `~/openclaw-stop.sh`

### `openclaw-status.sh`
Shows service status
- Service state
- Process information
- Resource usage

**Location**: `~/openclaw-status.sh`

### `openclaw-logs.sh`
Displays live logs
- Tails gateway log file
- Shows real-time activity

**Location**: `~/openclaw-logs.sh`

### `health-check.sh`
Comprehensive health monitoring
- Service status
- Wake lock status
- Resource usage
- Network connectivity
- Recent logs
- Error detection

**Usage**: `./health-check.sh`

### `update-openclaw.sh`
Updates OpenClaw to latest version
- Stops service if running
- Pulls latest code
- Rebuilds application
- Restarts service

**Usage**: `./update-openclaw.sh`

---

## Documentation Files

### `README.md`
Comprehensive guide covering:
- Project overview
- Features
- Installation instructions
- Usage examples
- Configuration details
- Troubleshooting basics
- Architecture overview

**Audience**: All users

### `QUICKSTART.md`
Fast-track guide for:
- 5-minute installation
- Basic configuration
- Essential commands
- Common tasks
- Quick troubleshooting

**Audience**: New users

### `TROUBLESHOOTING.md`
Detailed problem-solving guide:
- Common issues (17 scenarios)
- Solutions for each issue
- Diagnostic commands
- Prevention tips
- How to get help

**Audience**: Users experiencing problems

### `PERFORMANCE.md`
Performance optimization guide:
- Hardware specifications
- 3 optimization levels
- CPU/memory tuning
- Battery optimization
- Channel-specific optimizations
- Monitoring and benchmarking
- Recommended configurations

**Audience**: Power users, performance tuning

### `LICENSE`
MIT License for the project

---

## Directory Structure After Installation

```
Android Device
└── Termux
    ├── ~/luna/                              # This repository
    │   ├── install-termux.sh               # Main installer
    │   ├── termux-openclaw-service.sh      # Service runner
    │   ├── start-openclaw-boot.sh          # Boot script
    │   ├── health-check.sh                 # Health monitoring
    │   ├── update-openclaw.sh              # Update script
    │   ├── openclaw-termux.json            # Basic config template
    │   ├── openclaw-advanced.json          # Advanced config template
    │   ├── README.md                       # Main documentation
    │   ├── QUICKSTART.md                   # Quick start guide
    │   ├── TROUBLESHOOTING.md              # Troubleshooting guide
    │   ├── PERFORMANCE.md                  # Performance guide
    │   └── LICENSE                         # MIT License
    │
    ├── ~/openclaw/                          # OpenClaw repository
    │   ├── dist/                           # Built application
    │   ├── packages/                       # Source code
    │   └── ...                             # OpenClaw files
    │
    ├── ~/.openclaw/                         # OpenClaw data directory
    │   ├── openclaw.json                   # Active configuration
    │   ├── logs/                           # Log files
    │   │   ├── gateway.log                 # Gateway logs
    │   │   └── service-YYYYMMDD.log        # Service logs
    │   ├── workspace/                      # Agent workspace
    │   │   └── skills/                     # Installed skills
    │   ├── credentials/                    # Channel credentials
    │   └── sessions/                       # Session data
    │
    ├── ~/openclaw-start.sh                  # Start service
    ├── ~/openclaw-stop.sh                   # Stop service
    ├── ~/openclaw-status.sh                 # Check status
    ├── ~/openclaw-logs.sh                   # View logs
    │
    ├── ~/.termux/boot/                      # Boot scripts
    │   └── start-openclaw.sh               # Auto-start link
    │
    └── $PREFIX/var/service/openclaw/        # Service definition
        └── run                             # Service run script
```

---

## File Purposes Summary

| File | Purpose | Type |
|------|---------|------|
| `install-termux.sh` | Install and setup OpenClaw | Installer |
| `termux-openclaw-service.sh` | Background service runner | Service |
| `start-openclaw-boot.sh` | Auto-start on device boot | Boot script |
| `openclaw-start.sh` | Start OpenClaw manually | Utility |
| `openclaw-stop.sh` | Stop OpenClaw manually | Utility |
| `openclaw-status.sh` | Check service status | Utility |
| `openclaw-logs.sh` | View live logs | Utility |
| `health-check.sh` | Monitor system health | Diagnostic |
| `update-openclaw.sh` | Update to latest version | Maintenance |
| `openclaw-termux.json` | Basic configuration | Config |
| `openclaw-advanced.json` | Advanced configuration | Config |
| `README.md` | Full documentation | Docs |
| `QUICKSTART.md` | Quick start guide | Docs |
| `TROUBLESHOOTING.md` | Problem solving | Docs |
| `PERFORMANCE.md` | Performance tuning | Docs |
| `LICENSE` | MIT License | Legal |

---

## Installation Flow

```
1. User clones luna repository
   ↓
2. Runs ./install-termux.sh
   ↓
3. Script updates Termux packages
   ↓
4. Installs Node.js and dependencies
   ↓
5. Clones OpenClaw repository
   ↓
6. Builds OpenClaw (ui + core)
   ↓
7. Sets up service in $PREFIX/var/service/openclaw/
   ↓
8. Creates convenience scripts in ~/
   ↓
9. Copies config to ~/.openclaw/openclaw.json
   ↓
10. User edits config (API keys, passwords)
   ↓
11. User runs ~/openclaw-start.sh
   ↓
12. Service starts with auto-restart
   ↓
13. User accesses via web interface or channels
```

---

## Maintenance Workflow

### Daily
- Service runs automatically in background
- Logs rotate automatically
- Auto-restarts on crash

### Weekly
- Check health: `./health-check.sh`
- Review logs for errors
- Monitor resource usage

### Monthly
- Update OpenClaw: `./update-openclaw.sh`
- Clean old logs: `find ~/.openclaw/logs -name "*.log" -mtime +30 -delete`
- Backup configuration: `cp ~/.openclaw/openclaw.json ~/config-backup.json`

---

## Key Features

✅ **One-command installation**
✅ **Automatic service management**
✅ **Auto-restart on failure**
✅ **Wake lock for 24/7 operation**
✅ **Multi-core CPU utilization**
✅ **Memory-optimized for 4GB RAM**
✅ **Comprehensive logging**
✅ **Health monitoring**
✅ **Easy updates**
✅ **Detailed documentation**
✅ **Troubleshooting guides**
✅ **Performance tuning**

---

## Next Steps for Users

1. **Install Termux apps from F-Droid**:
   - Termux
   - Termux:Boot
   - Termux:API

2. **Clone and install**:
   ```bash
   git clone https://github.com/cosmic-hydra/luna.git
   cd luna
   ./install-termux.sh
   ```

3. **Configure**:
   ```bash
   nano ~/.openclaw/openclaw.json
   # Add API keys and set password
   ```

4. **Start**:
   ```bash
   ~/openclaw-start.sh
   ```

5. **Access**:
   - Web: http://YOUR_IP:18789
   - Telegram: Message your bot
   - Discord: Invite bot to server

6. **Enable auto-start**:
   ```bash
   mkdir -p ~/.termux/boot
   ln -s ~/luna/start-openclaw-boot.sh ~/.termux/boot/start-openclaw.sh
   ```

7. **Optimize**:
   - Read PERFORMANCE.md
   - Adjust based on usage
   - Monitor with health-check.sh

---

## Support Resources

- **Quick Start**: QUICKSTART.md
- **Full Guide**: README.md
- **Problems**: TROUBLESHOOTING.md
- **Optimization**: PERFORMANCE.md
- **OpenClaw Docs**: https://docs.openclaw.ai
- **Discord**: https://discord.gg/clawd
- **Issues**: https://github.com/cosmic-hydra/luna/issues

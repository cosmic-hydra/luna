# OpenClaw Bypass Installer - Quick Reference

## What Was Changed

### New Files Created

1. **install-openclaw-bypass.sh** - Main bypass installer
   - One-command automated installation
   - No manual configuration needed
   - Works on both Termux and Linux

2. **BYPASS-INSTALL.md** - Complete documentation
   - Installation guide
   - Performance tuning
   - Troubleshooting
   - Advanced configuration

3. **openclaw-ultra.json** - Ultra-performance config template
   - 16 concurrent tasks
   - Browser automation enabled
   - Unlimited memory mode
   - All channels available

### Updated Files

1. **termux-openclaw-service.sh** - Service runner upgraded
   - Memory: 8GB soft limit (was 1GB)
   - Thread pool: 4x CPU cores (was 8 fixed)
   - Added io_uring support
   - Performance monitoring

2. **README.md** - Installation instructions updated
   - Bypass install as recommended method
   - Standard install as conservative option
   - Clear feature comparison

## Key Performance Improvements

### Memory Configuration

**Before:**
```bash
export NODE_OPTIONS="--max-old-space-size=1024"  # 1GB limit
```

**After:**
```bash
export NODE_OPTIONS="--max-old-space-size=8192 --max-semi-space-size=64 --expose-gc"  # 8GB
```

### CPU Configuration

**Before:**
```bash
export UV_THREADPOOL_SIZE=8  # Fixed 8 threads
```

**After:**
```bash
CORES=$(nproc)
export UV_THREADPOOL_SIZE=$((CORES * 4))  # 4x CPU cores
export UV_USE_IO_URING=1  # Advanced I/O
```

### Concurrent Tasks

**Before:** 4 tasks
**After:** 16 tasks

## Installation Methods

### Bypass Installation (NEW)

```bash
./install-openclaw-bypass.sh
```

**Features:**
- No memory limits
- All CPU cores (4x multiplier)
- Browser enabled
- 16 concurrent tasks
- Automated setup

**Best for:**
- Maximum performance
- Devices with 4GB+ RAM
- 24/7 operation
- Heavy workloads

### Standard Installation

```bash
./install-termux.sh
```

**Features:**
- 1GB memory limit
- 8 threads fixed
- Browser disabled
- 4 concurrent tasks
- Manual configuration

**Best for:**
- Conservative resource usage
- Devices with 2-4GB RAM
- Light to medium usage
- Battery conservation

## Performance Comparison

| Metric | Standard | Bypass | Improvement |
|--------|----------|--------|-------------|
| Memory Limit | 1GB | 8GB | 8x |
| Thread Pool | 8 | 32 (on 8-core) | 4x |
| Concurrent Tasks | 4 | 16 | 4x |
| Browser | Disabled | Enabled | ✓ |
| Installation Steps | ~10 manual | 1 command | - |

## Example Performance

### Samsung S6 Lite (8 cores, 4GB RAM)

**Bypass Mode:**
- Thread Pool: 32 threads
- Concurrent Tasks: 16
- Memory: Up to 4GB available
- CPU Usage: ~60-80%

**Standard Mode:**
- Thread Pool: 8 threads
- Concurrent Tasks: 4
- Memory: Max 1GB
- CPU Usage: ~30-50%

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

Shows:
- Service status
- CPU/memory usage
- Thread count
- Core count
- Performance mode

### View Logs

```bash
~/openclaw-logs.sh
```

## Important Notes

1. **Change Password**: Edit `~/.openclaw/openclaw.json` and set a strong password

2. **Add API Keys**:
```bash
export ANTHROPIC_API_KEY="your-key"
export OPENAI_API_KEY="your-key"
```

3. **Monitor Resources**: Check status regularly to ensure stability

4. **Battery Optimization**: Disable battery optimization for Termux in Android settings

## Troubleshooting

### Out of Memory

Reduce concurrent tasks:
```json
{ "performance": { "maxConcurrentTasks": 8 } }
```

### High CPU Usage

Lower thread pool in service script:
```bash
export UV_THREADPOOL_SIZE=16  # Instead of 4x
```

### Service Won't Start

Check logs:
```bash
cat ~/.openclaw/logs/service-$(date +%Y%m%d).log
```

## Files Location

- Installer: `./install-openclaw-bypass.sh`
- Documentation: `./BYPASS-INSTALL.md`
- Config Template: `./openclaw-ultra.json`
- Service Script: `./termux-openclaw-service.sh`
- OpenClaw Install: `~/openclaw/`
- Configuration: `~/.openclaw/openclaw.json`
- Logs: `~/.openclaw/logs/`

## Next Steps

1. Run the bypass installer
2. Configure API keys
3. Set password
4. Enable desired channels
5. Start OpenClaw
6. Monitor performance
7. Adjust as needed

---

**For full documentation, see [BYPASS-INSTALL.md](BYPASS-INSTALL.md)**

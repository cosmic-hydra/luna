#!/data/data/com.termux/files/usr/bin/bash
# Verify OpenClaw Ultra-Performance Installation

echo "========================================"
echo "OpenClaw Ultra-Performance Verification"
echo "========================================"
echo ""

# Check if files exist
echo "Checking installation files..."
FILES=(
    "install-openclaw-bypass.sh"
    "BYPASS-INSTALL.md"
    "QUICKSTART-BYPASS.md"
    "openclaw-ultra.json"
    "termux-openclaw-service.sh"
)

ALL_EXIST=1
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ $file"
    else
        echo "✗ $file (missing)"
        ALL_EXIST=0
    fi
done

echo ""

# Check if installer is executable
if [ -x "install-openclaw-bypass.sh" ]; then
    echo "✓ Bypass installer is executable"
else
    echo "✗ Bypass installer is not executable"
    echo "  Fix: chmod +x install-openclaw-bypass.sh"
    ALL_EXIST=0
fi

echo ""

# Show key features
echo "Ultra-Performance Features:"
echo "  • Memory: UNLIMITED (8GB soft limit)"
echo "  • CPU Cores: ALL available"
echo "  • Thread Pool: 4x CPU cores"
echo "  • Concurrent Tasks: 16"
echo "  • Browser: Enabled"
echo ""

# Show installation command
echo "To install OpenClaw with ultra-performance:"
echo "  ./install-openclaw-bypass.sh"
echo ""

# Show documentation
echo "Documentation:"
echo "  • Complete Guide: BYPASS-INSTALL.md"
echo "  • Quick Reference: QUICKSTART-BYPASS.md"
echo "  • Implementation: IMPLEMENTATION-SUMMARY.md"
echo ""

if [ $ALL_EXIST -eq 1 ]; then
    echo "✓ All files present - ready to install!"
    exit 0
else
    echo "✗ Some files are missing"
    exit 1
fi

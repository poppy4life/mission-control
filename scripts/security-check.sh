#!/bin/bash
# Comprehensive Silent Security Monitor for OpenClaw
# Runs all checks and only sends alerts when issues are detected

# Config
THRESHOLD_DISK=90
CHECK_HOURS=6
ALERT_COUNT=0
ALERT_MSG=""

# Function to add alert
add_alert() {
    ALERT_COUNT=$((ALERT_COUNT + 1))
    ALERT_MSG="${ALERT_MSG}
$1"
}

# ============================================
# 1. DISK SPACE CHECK
# ============================================
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$USAGE" -ge "$THRESHOLD_DISK" ]; then
    add_alert "🚨 DISK SPACE CRITICAL: ${USAGE}% used (threshold: ${THRESHOLD}%)"
    add_alert "   Action needed: Free up space immediately"
fi

# ============================================
# 2. SSH SECURITY CHECK
# ============================================
# Check if SSH is enabled (port 22 listening)
if lsof -nP -iTCP:22 -sTCP:LISTEN >/dev/null 2>&1; then
    # SSH is enabled - check for attacks
    FAILED=$(log show --predicate 'subsystem == "com.openssh.sshd" AND eventMessage CONTAINS "Failed"' --last ${CHECK_H}h 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$FAILED" -gt 5 ]; then
        add_alert "🚨 SSH ATTACK DETECTED: $FAILED failed attempts in last ${CHECK_H}h"
        add_alert "   SSH is ENABLED - recommend disabling or hardening"
    fi
else
    # SSH disabled - this is secure, no alert needed
    :
fi

# ============================================
# 3. CONFIG AUDIT
# ============================================
CONFIG_DIR="$HOME/.openclaw"
if [ -d "$CONFIG_DIR" ]; then
    # Check for suspicious changes in last 24h
    CHANGES=$(find "$CONFIG_DIR" -name "openclaw.json" -mtime -1 2>/dev/null)
    
    if [ -n "$CHANGES" ]; then
        add_alert "⚠️ CONFIG CHANGED: OpenClaw configuration modified in last 24h"
        add_alert "   Review: $CHANGES"
    fi
fi

# ============================================
# SEND ALERT IF ANY ISSUES FOUND
# ============================================
if [ "$ALERT_COUNT" -gt 0 ]; then
    echo "🔐 Security Alert: $ALERT_COUNT issue(s) detected"
    echo "$ALERT_MSG"
    echo ""
    echo "Run ./security-silent.sh for full details"
    exit 1  # Signal alert
else
    # Silent success
    exit 0
fi

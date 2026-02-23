#!/bin/bash
# Silent Security Monitoring for OpenClaw
# Only alerts when there's an actual issue

ALERT_FILE="/tmp/openclaw-security-alert.tmp"

# Clear any old alerts
rm -f "$ALERT_FILE"

# ============================================
# 1. DISK SPACE ALERT (only if >90%)
# ============================================
disk_alert() {
    local threshold=90
    local usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$usage" -ge "$threshold" ]; then
        echo "🚨 DISK SPACE CRITICAL" >> "$ALERT_FILE"
        echo "Usage: ${usage}% (threshold: ${threshold}%)" >> "$ALERT_FILE"
        echo "Action: Clean up files immediately" >> "$ALERT_FILE"
        echo "" >> "$ALERT_FILE"
    fi
}

# ============================================
# 2. SSH ATTACK ALERT (only if failed attempts found)
# ============================================
ssh_alert() {
    local failed_count=0
    
    # Check for suspicious activity
    if command -v log >/dev/null 2>&1; then
        failed_count=$(log show --predicate 'subsystem == "com.openssh.sshd" AND eventMessage CONTAINS "Failed"' --last 6h 2>/dev/null | wc -l | tr -d ' ')
    fi
    
    # If SSH is enabled, check for brute force
    if lsof -nP -iTCP:22 -sTCP:LISTEN >/dev/null 2>&1; then
        if [ "$failed_count" -gt 5 ]; then
            echo "🚨 SSH BRUTE FORCE DETECTED" >> "$ALERT_FILE"
            echo "Failed attempts in last 6h: $failed_count" >> "$ALERT_FILE"
            echo "SSH is ENABLED - consider disabling or hardening" >> "$ALERT_FILE"
            echo "" >> "$ALERT_FILE"
        fi
    fi
}

# ============================================
# 3. CONFIG CHANGES ALERT (only if suspicious changes)
# ============================================
config_alert() {
    local config_dir="$HOME/.openclaw"
    local suspicious=false
    local changes=""
    
    # Check for recent config changes (last 24 hours)
    if [ -d "$config_dir" ]; then
        changes=$(find "$config_dir" -name "*.json" -mtime -1 2>/dev/null | head -5)
        
        # Only alert if gateway or auth config changed
        if echo "$changes" | grep -q "openclaw.json"; then
            suspicious=true
        fi
    fi
    
    if [ "$suspicious" = true ]; then
        echo "⚠️ CONFIG CHANGES DETECTED" >> "$ALERT_FILE"
        echo "Modified files:" >> "$ALERT_FILE"
        echo "$changes" >> "$ALERT_FILE"
        echo "Review these changes if unexpected" >> "$ALERT_FILE"
        echo "" >> "$ALERT_FILE"
    fi
}

# ============================================
# MAIN - Run all checks
# ============================================
case "$1" in
    disk)
        disk_alert
        ;;
    ssh)
        ssh_alert
        ;;
    config)
        config_alert
        ;;
    all)
        disk_alert
        ssh_alert
        config_alert
        ;;
    *)
        echo "Usage: $0 {disk|ssh|config|all}"
        exit 1
        ;;
esac

# If alerts were generated, output them for OpenClaw to send
if [ -f "$ALERT_FILE" ]; then
    cat "$ALERT_FILE"
    rm -f "$ALERT_FILE"
    exit 1  # Signal that alert was triggered
else
    # Silent success - no output
    exit 0
fi

#!/bin/bash
# Security Monitoring Scripts for OpenClaw
# Created: 2025-02-23
# Purpose: Monitor system security and alert via OpenClaw

# ============================================
# 1. DISK SPACE MONITOR
# ============================================
disk_check() {
    local threshold=90
    local usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    
    if [ "$usage" -ge "$threshold" ]; then
        echo "🚨 ALERT: Disk space critical! ${usage}% used"
        echo "Clean up space immediately to prevent crashes"
        df -h /
    else
        echo "✅ Disk space OK: ${usage}% used"
    fi
}

# ============================================
# 2. SSH LOGIN MONITOR (macOS)
# ============================================
ssh_monitor() {
    local log_file="/var/log/system.log"
    local failed_attempts=0
    
    # Check for failed SSH attempts in last 15 minutes
    if [ -f "$log_file" ]; then
        failed_attempts=$(log show --predicate 'subsystem == "com.openssh.sshd"' --last 15m 2>/dev/null | grep -c "Failed" || echo "0")
    fi
    
    # Also check for any sshd activity
    local ssh_activity=$(log show --predicate 'subsystem == "com.openssh.sshd"' --last 15m 2>/dev/null | wc -l)
    
    if [ "$failed_attempts" -gt 0 ]; then
        echo "🚨 SECURITY ALERT: $failed_attempts failed SSH login attempts in last 15 minutes!"
        echo "Someone may be trying to brute force your server"
    elif [ "$ssh_activity" -gt 0 ]; then
        echo "🔐 SSH activity detected: $ssh_activity events (review if unexpected)"
    else
        echo "✅ No suspicious SSH activity in last 15 minutes"
    fi
}

# ============================================
# 3. CONFIG AUDIT
# ============================================
config_audit() {
    local config_dir="$HOME/.openclaw"
    local changes_detected=false
    local report=""
    
    # Check for recent config changes (last 24 hours)
    if [ -d "$config_dir" ]; then
        local recent_changes=$(find "$config_dir" -name "*.json" -mtime -1 2>/dev/null)
        
        if [ -n "$recent_changes" ]; then
            changes_detected=true
            report="Recent config changes detected:\n$recent_changes"
        fi
    fi
    
    # Check OpenClaw gateway config
    if [ -f "$config_dir/openclaw.json" ]; then
        local config_hash=$(md5 -q "$config_dir/openclaw.json" 2>/dev/null)
        echo "Config hash: $config_hash"
    fi
    
    if [ "$changes_detected" = true ]; then
        echo "⚠️ CONFIG CHANGES: $report"
        echo "Review these changes to ensure they're authorized"
    else
        echo "✅ No unauthorized config changes detected"
    fi
}

# ============================================
# MAIN EXECUTION
# ============================================
case "$1" in
    disk)
        disk_check
        ;;
    ssh)
        ssh_monitor
        ;;
    config)
        config_audit
        ;;
    all)
        echo "=== SECURITY CHECK: $(date) ==="
        echo ""
        echo "--- Disk Space ---"
        disk_check
        echo ""
        echo "--- SSH Monitor ---"
        ssh_monitor
        echo ""
        echo "--- Config Audit ---"
        config_audit
        echo ""
        echo "=== END SECURITY CHECK ==="
        ;;
    *)
        echo "Usage: $0 {disk|ssh|config|all}"
        exit 1
        ;;
esac

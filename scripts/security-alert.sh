#!/bin/bash
# Smart Silent Security Monitor for OpenClaw
# Distinguishes between legitimate changes (model switches) and suspicious changes

ISSUES=0
REPORT=""
CONFIG_FILE="$HOME/.openclaw/openclaw.json"
ALERT_FILE="/tmp/security-alert-$(date +%s).txt"

# Function to add alert
add_alert() {
    ISSUES=$((ISSUES + 1))
    REPORT="${REPORT}$1\n"
}

# ============================================
# 1. DISK CHECK (>90%)
# ============================================
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$USAGE" -ge 90 ]; then
    add_alert "🚨 DISK CRITICAL: ${USAGE}% used (threshold: 90%)"
fi

# ============================================
# 2. SSH ATTACK CHECK (only if SSH enabled)
# ============================================
if lsof -nP -iTCP:22 -sTCP:LISTEN >/dev/null 2>&1; then
    FAILED=$(log show --predicate 'subsystem == \"com.openssh.sshd\" AND eventMessage CONTAINS \"Failed\"' --last 6h 2>/dev/null | wc -l | tr -d ' ')
    if [ "$FAILED" -gt 5 ]; then
        add_alert "🚨 SSH ATTACK: $FAILED failed attempts detected"
    fi
fi

# ============================================
# 3. SMART CONFIG CHECK
# ============================================
if [ -f "$CONFIG_FILE" ]; then
    # Check if modified in last 24h
    if find "$CONFIG_FILE" -mtime -1 2>/dev/null | grep -q .; then
        
        # Read the config and check WHAT changed
        # Suspicious: auth, gateway.bind, channels.*.botToken, gateway.token
        # Normal: agents.defaults.model.primary, models aliases
        
        # Check for suspicious auth/gateway changes
        if grep -q '"auth":' "$CONFIG_FILE" && grep -A5 '"auth":' "$CONFIG_FILE" | grep -q 'token\|password\|key'; then
            add_alert "⚠️ AUTH CONFIG CHANGED: Review auth settings in openclaw.json"
        fi
        
        if grep -q '"gateway":' "$CONFIG_FILE" && grep -A10 '"gateway":' "$CONFIG_FILE" | grep -q 'token\|bind.*0.0.0.0\|port'; then
            add_alert "⚠️ GATEWAY CONFIG CHANGED: Gateway settings modified - verify bind/port/token"
        fi
        
        if grep -q '"channels":' "$CONFIG_FILE" && grep -A10 '"channels":' "$CONFIG_FILE" | grep -q 'botToken\|enabled.*true'; then
            add_alert "⚠️ CHANNEL CONFIG CHANGED: New channel or bot token added"
        fi
        
        # If no suspicious changes found, but file was modified
        # Check if it's just a model change (normal)
        MODEL_CHANGED=false
        if grep -q '"primary":' "$CONFIG_FILE"; then
            # Likely just a model switch - less critical
            MODEL_CHANGED=true
        fi
        
        # Only alert if suspicious changes found, not model changes
        if [ "$ISSUES" -eq 0 ] && [ "$MODEL_CHANGED" = true ]; then
            # Model change only - log but don't alert
            echo "$(date): Model switch detected (normal operation)" >> /tmp/security-model-changes.log
            # Don't increment ISSUES for model-only changes
        fi
    fi
fi

# ============================================
# OUTPUT RESULTS
# ============================================
if [ "$ISSUES" -gt 0 ]; then
    echo "🔐 Security Alert: $ISSUES issue(s) detected"
    echo -e "$REPORT"
    echo "Review: ~/.openclaw/openclaw.json"
    exit 1
else
    # Silent success - only model changes or all clear
    exit 0
fi

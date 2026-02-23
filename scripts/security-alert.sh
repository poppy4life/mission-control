#!/bin/bash
# Silent Security Monitor - Comprehensive Check
# Outputs ONLY when issues are detected

ISSUES=0
REPORT=""

# 1. DISK CHECK (>90%)
USAGE=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ "$USAGE" -ge 90 ]; then
    ISSUES=$((ISSUES + 1))
    REPORT="${REPORT}🚨 DISK CRITICAL: ${USAGE}% used\n"
fi

# 2. SSH CHECK (if enabled, check for attacks)
if lsof -nP -iTCP:22 -sTCP:LISTEN >/dev/null 2>&1; then
    FAILED=$(log show --predicate 'subsystem == "com.openssh.sshd" AND eventMessage CONTAINS "Failed"' --last 6h 2>/dev/null | wc -l | tr -d ' ')
    if [ "$FAILED" -gt 5 ]; then
        ISSUES=$((ISSUES + 1))
        REPORT="${REPORT}🚨 SSH ATTACK: $FAILED failed attempts\n"
    fi
fi

# 3. CONFIG CHECK (suspicious changes)
if find ~/.openclaw -name "openclaw.json" -mtime -1 2>/dev/null | grep -q .; then
    ISSUES=$((ISSUES + 1))
    REPORT="${REPORT}⚠️ CONFIG CHANGED: Review openclaw.json\n"
fi

# Output only if issues found
if [ "$ISSUES" -gt 0 ]; then
    echo -e "🔐 Security Alert: $ISSUES issue(s) detected\n$REPORT"
    exit 1
fi

# Silent success
exit 0

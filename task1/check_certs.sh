#!/bin/bash
# Reads sites from config and checks their cert expiration dates

CONFIG_FILE="${CONFIG_FILE:-/etc/cert-checker/sites.conf}"
WARN_DAYS="${WARN_DAYS:-30}"
CRIT_DAYS="${CRIT_DAYS:-7}"
SLACK_WEBHOOK="${SLACK_WEBHOOK:-}"

# colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_ok() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# send slack notification if webhook is set
send_slack_alert() {
    local message="$1"
    local level="$2"

    [ -z "$SLACK_WEBHOOK" ] && return

    local color="good"
    [ "$level" = "warn" ] && color="warning"
    [ "$level" = "critical" ] && color="danger"

    curl -s -X POST "$SLACK_WEBHOOK" \
        -H 'Content-type: application/json' \
        -d "{\"attachments\":[{\"color\":\"$color\",\"text\":\"$message\"}]}" \
        > /dev/null 2>&1
}

# get cert expiry date for a domain
get_cert_expiry() {
    local domain="$1"
    local port="${2:-443}"

    # fetch cert and extract expiry
    expiry_date=$(echo | timeout 10 openssl s_client -servername "$domain" \
        -connect "${domain}:${port}" 2>/dev/null | \
        openssl x509 -noout -enddate 2>/dev/null | \
        cut -d= -f2)

    if [ -z "$expiry_date" ]; then
        return 1
    fi

    echo "$expiry_date"
}

# calculate days until expiry
days_until_expiry() {
    local expiry_date="$1"

    expiry_epoch=$(date -d "$expiry_date" +%s 2>/dev/null)
    if [ $? -ne 0 ]; then
        return 1
    fi

    now_epoch=$(date +%s)
    diff_seconds=$((expiry_epoch - now_epoch))
    diff_days=$((diff_seconds / 86400))

    echo "$diff_days"
}

# main check function
check_site() {
    local site="$1"

    # skip comments and empty lines
    [[ "$site" =~ ^#.*$ ]] && return
    [[ -z "$site" ]] && return

    # parse domain:port if specified
    domain=$(echo "$site" | cut -d: -f1)
    port=$(echo "$site" | cut -d: -f2 -s)
    port="${port:-443}"

    expiry=$(get_cert_expiry "$domain" "$port")
    if [ $? -ne 0 ]; then
        log_error "$domain - failed to retrieve certificate"
        send_slack_alert "$domain - could not retrieve SSL certificate" "critical"
        return 1
    fi

    days_left=$(days_until_expiry "$expiry")
    if [ $? -ne 0 ]; then
        log_error "$domain - failed to parse expiry date"
        return 1
    fi

    # format expiry for display
    expiry_formatted=$(date -d "$expiry" "+%Y-%m-%d %H:%M:%S" 2>/dev/null)

    # check thresholds
    if [ "$days_left" -le "$CRIT_DAYS" ]; then
        log_error "$domain - expires in $days_left days ($expiry_formatted)"
        send_slack_alert "$domain - certificate expires in $days_left days" "critical"
    elif [ "$days_left" -le "$WARN_DAYS" ]; then
        log_warn "$domain - expires in $days_left days ($expiry_formatted)"
        send_slack_alert "$domain - certificate expires in $days_left days" "warn"
    else
        log_ok "$domain - expires in $days_left days ($expiry_formatted)"
    fi
}

# main

if [ ! -f "$CONFIG_FILE" ]; then
    log_error "Config file not found: $CONFIG_FILE"
    exit 1
fi

echo "========================================"
echo "SSL Certificate expiry checker"
echo "Started: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Warning threshold: $WARN_DAYS days"
echo "Critical threshold: $CRIT_DAYS days"
echo "========================================"
echo ""

while IFS= read -r site || [ -n "$site" ]; do
    check_site "$site"
done < "$CONFIG_FILE"

echo ""
echo "Check completed."

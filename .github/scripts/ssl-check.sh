#!/bin/bash

SLACK_WEBHOOK_URL=$1
DOMAIN_LIST=$2

function sendSlackNotification {
  local domain=$1
  local daysLeft=$2

  local message="SSL Expiry Alert\n"
  message+="   * Domain: $domain\n"
  message+="   * Warning: The SSL certificate for $domain will expire in $daysLeft days."

  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL"
}

while IFS= read -r domain; do
  expiry_date=$(openssl s_client -servername "$domain" -connect "$domain":443 </dev/null 2>/dev/null | openssl x509 -noout -enddate | sed 's/notAfter=//')
  expiry_timestamp=$(date -d "$expiry_date" +%s)
  current_timestamp=$(date +%s)
  days_left=$(( ($expiry_timestamp - $current_timestamp) / 86400 ))

  if [ "$days_left" -lt 30 ]; then
    sendSlackNotification "$domain" "$days_left"
  fi
done <<< "$DOMAIN_LIST"

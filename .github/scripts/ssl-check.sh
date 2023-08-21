#!/bin/bash

DOMAIN_LIST=$DOMAIN_LIST
SLACK_WEBHOOK_URL=$SLACK_WEBHOOK_URL 


function sendSlackNotification {
  local message="$1"

  curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL"
}

for DOMAIN in $DOMAIN_LIST
do
  EXPIRY_DATE=$( echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | sed 's/notAfter=//' )
  EXPIRYSIMPLE=$( date -d "$EXPIRY_DATE" +%F )
  EXPIRYSEC=$( date -d "$EXPIRY_DATE" +%s )
  TODAYSEC=$( date +%s )
  EXPIRYCALC=$(( ($EXPIRYSEC - $TODAYSEC) / 86400 ))
  
  if [ $EXPIRYCALC -lt 30 ] ; then
    alert_message="######ALERT####### $DOMAIN Cert needs to be renewed."
    sendSlackNotification "$alert_message"
  fi
done


# function sendSlackNotification {
#   local message="$1"

#   echo "Sending message to Slack: $message"
#   curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL"
# }

# # ... (rest of your script)

# for DOMAIN in $DOMAINLIST
# do
#   EXPIRY_DATE=$( echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | sed 's/notAfter=//' )
#   EXPIRYSIMPLE=$( date -d "$EXPIRY_DATE" +%F )
#   EXPIRYSEC=$( date -d "$EXPIRY_DATE" +%s )
#   TODAYSEC=$( date +%s )
#   EXPIRYCALC=$(( ($EXPIRYSEC - $TODAYSEC) / 86400 ))
#   # Output
#   if [ $EXPIRYCALC -lt $EXPIRYALERTDAYS ] ;
#   then
#     alert_message="######ALERT####### $DOMAIN Cert needs to be renewed."
#     sendSlackNotification "$alert_message"
#   fi
#   echo "$EXPIRYSIMPLE - $DOMAIN expires (in $EXPIRYCALC days)"
# done


# function sendSlackNotification {
#   local message="$1"

#   curl -X POST -H 'Content-type: application/json' --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL"
# }

# # ... (rest of your script)

# for DOMAIN in $DOMAINLIST
# do
#   EXPIRY=$( echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | sed 's/notAfter=//')
#   EXPIRYSIMPLE=$( date -d "$EXPIRY" +%F )
#   EXPIRYSEC=$(date -d "$EXPIRY" +%s)
#   TODAYSEC=$(date +%s)
#   EXPIRYCALC=$(echo "($EXPIRYSEC-$TODAYSEC)/86400" | bc )
#   # Output
#   if [ $EXPIRYCALC -lt $EXPIRYALERTDAYS ] ;
#   then
#     alert_message="######ALERT####### $DOMAIN Cert needs to be renewed."
#     sendSlackNotification "$alert_message"
#   fi
#   echo "$EXPIRYSIMPLE - $DOMAIN expires (in $EXPIRYCALC days)"
# done

#   if [ "$days_left" -lt 30 ]; then
#     sendSlackNotification "$domain" "$days_left"
#   fi
# done <<< "$DOMAIN_LIST"

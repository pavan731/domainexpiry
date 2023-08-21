#!/bin/bash
# Requires openssl, bc, grep, sed, date, mutt, sort

## Edit these ##
# Space separated list of domains to check
DOMAINLIST="hp.com github.com google.com"
# Where to send the report
SLACK_WEBHOOK_URL="https://hooks.slack.com/services/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"
# Logfile/report location
REPORTEMAIL=me@example.com
# Additional alert warning prepended if domain has less than this number of days before expiry
EXPIRYALERTDAYS=150
# Logfile/report location
LOGFILE=/tmp/SSLreport.txt
## Editing finished ##

# Clear last log
echo "" > $LOGFILE

for DOMAIN in $DOMAINLIST
do
    EXPIRY=$( echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:443 2>/dev/null | openssl x509 -noout -dates | grep notAfter | sed 's/notAfter=//')
    EXPIRYSIMPLE=$( date -d "$EXPIRY" +%F )
    EXPIRYSEC=$(date -d "$EXPIRY" +%s)
    TODAYSEC=$(date +%s)
    EXPIRYCALC=$(echo "($EXPIRYSEC-$TODAYSEC)/86400" | bc )
    # Output
    if [ $EXPIRYCALC -lt $EXPIRYALERTDAYS ] ;
    then
        echo "######ALERT####### $DOMAIN Cert needs to be renewed." >> $LOGFILE
    fi
    echo "$EXPIRYSIMPLE - $DOMAIN expires (in $EXPIRYCALC days)" >> $LOGFILE
done

# Report
sort -n -o $LOGFILE $LOGFILE 

# Sending report to Slack
curl -X POST -H 'Content-type: application/json' --data '{
  "text": "SSL Report on '"$(date)"'",
  "attachments": [
    {
      "text": "'"$(cat $LOGFILE | sed 's/"/\\"/g')"'"
    }
  ]
}' $SLACK_WEBHOOK_URL

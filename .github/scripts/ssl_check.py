#!/usr/bin/env python3

import socket
import ssl
import datetime
import requests

class ssl_check():
    def __init__(self, hostname):
        print("%s" % hostname)
        ssl_date_fmt = r'%b %d %H:%M:%S %Y %Z'
        context = ssl.create_default_context()
        conn = context.wrap_socket(socket.socket(socket.AF_INET), server_hostname=hostname)
        conn.settimeout(3.0)
        conn.connect((hostname, 443))
        ssl_info = conn.getpeercert()
        Exp_ON = datetime.datetime.strptime(ssl_info['notAfter'], ssl_date_fmt)
        Days_Remaining = (Exp_ON - datetime.datetime.utcnow()).days

        # Format the Slack message
        slack_message = (
            f"SSL Expiry Alert\n"
            f"* Domain: {hostname}\n"
            f"* Warning: The SSL certificate for {hostname} will expire in {Days_Remaining} days."
        )

        # Send the message to Slack
        send_to_slack(slack_message)

    def send_to_slack(message):
        webhook_url = "YOUR_SLACK_WEBHOOK_URL"  # Replace with your actual webhook URL
        payload = {"text": message}
        response = requests.post(webhook_url, json=payload)
        if response.status_code != 200:
            print("Failed to send message to Slack")

# Your list of domains
domains = ['google.com', 'yahoo.com', 'facebook.com', 'twitter.com']

for domain in domains:
    ssl_check(domain)

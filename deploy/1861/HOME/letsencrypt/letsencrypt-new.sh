#!/usr/bin/env bash

log_file="/var/log/letsencrypt/letsencrypt.log"

le_path="/opt/letsencrypt"
exp_limit=30
rsa-key-size=4096
authenticator=standalone
domain="1861.history.state.gov"
cert_file="/etc/letsencrypt/live/$domain/fullchain.pem"

echo "Stopping nginx" | tee -a "$log_file"
service nginx stop
echo "Starting renewal script..." | tee -a "$log_file"
$le_path/certbot-auto certonly --nginx --agree-tos --debug
echo "Reloading nginx" | tee -a "$log_file"
nginx -t && service nginx start
exit 0;

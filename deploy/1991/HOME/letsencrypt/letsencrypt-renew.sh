#!/usr/bin/env bash

config_file="$HOME/letsencrypt/cli-1991.history.state.gov.ini"
log_file="/var/log/letsencrypt/letsencrypt.log"

le_path="/opt/letsencrypt"
exp_limit=30;

domain=$(grep "^\s*domains" "$config_file" | sed "s/^\s*domains\s*=\s*//" | sed 's/(\s*)\|,.*$//')
cert_file="/etc/letsencrypt/live/$domain/fullchain.pem"

DATE=$(date "+%Y-%m-%d")
TIME=$(date "+%H:%M")
exp=$(date -d "$(openssl x509 -in "$cert_file" -text -noout|grep "Not After"|cut -c 25-)" +%s)
datenow=$(date -d "now" +%s)
days_exp=$(echo \( "$exp" - "$datenow" \) / 86400 |bc)

if [ ! -f "$config_file" ]; then
    echo "$DATE $TIME: [ERROR] config file does not exist: $config_file" | tee -a "$log_file"
    exit 1;
fi

if [ ! -f "$cert_file" ]; then
    echo "$DATE $TIME: [ERROR] certificate file not found for domain $domain." | tee -a "$log_file"
fi

echo "$DATE $TIME: Checking expiration date for $domain..." | tee -a "$log_file"

if [ "$days_exp" -gt "$exp_limit" ] ; then
    echo "$DATE $TIME: The certificate is up to date, no need for renewal ($days_exp days left)." | tee -a "$log_file"
    exit 0;
else
    echo "$DATE $TIME: The certificate for $domain is about to expire soon." | tee -a "$log_file"
    echo "Stopping nginx" | tee -a "$log_file"
    service nginx stop
    echo "Starting renewal script..." | tee -a "$log_file"
    $le_path/letsencrypt-auto certonly --agree-tos --renew-by-default --config "$config_file" --debug
    echo "Reloading nginx" | tee -a "$log_file"
    nginx -t && service nginx start
    echo "$DATE $TIME: Renewal process finished for domain $domain" | tee -a "$log_file"
    exit 0;
fi

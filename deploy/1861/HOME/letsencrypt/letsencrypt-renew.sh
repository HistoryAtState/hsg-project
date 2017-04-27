#!/usr/bin/env bash

config_file="$HOME/letsencrypt/cli-1861.history.state.gov.ini"

le_path="/opt/letsencrypt"
exp_limit=30;

if [ ! -f "$config_file" ]; then
  echo "[ERROR] config file does not exist: $config_file"
  exit 1;
fi

domain=$(grep "^\s*domains" "$config_file" | sed "s/^\s*domains\s*=\s*//" | sed 's/(\s*)\|,.*$//')
cert_file="/etc/letsencrypt/live/$domain/fullchain.pem"

if [ ! -f "$cert_file" ]; then
  echo "[ERROR] certificate file not found for domain $domain."
fi

DATE=$(date "+%Y-%m-%d")
TIME=$(date "+%H:%M")
exp=$(date -d "$(openssl x509 -in "$cert_file" -text -noout|grep "Not After"|cut -c 25-)" +%s)
datenow=$(date -d "now" +%s)
days_exp=$(echo \( "$exp" - "$datenow" \) / 86400 |bc)

echo "$DATE $TIME: Checking expiration date for $domain..."

if [ "$days_exp" -gt "$exp_limit" ] ; then
  echo "$DATE $TIME: The certificate is up to date, no need for renewal ($days_exp days left)."
  exit 0;
else
  echo "The certificate for $domain is about to expire soon."
  echo "Stopping nginx"
    service nginx stop
  echo "Starting renewal script..."
    $le_path/letsencrypt-auto certonly --agree-tos --renew-by-default --config "$config_file" --debug
  echo "Reloading nginx"
    nginx -t && service nginx start
  echo "Renewal process finished for domain $domain"
  exit 0;
fi

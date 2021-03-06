#!/usr/bin/env bash

# file with configurable options
config_path="/root/letsencrypt/"
config_file="/root/letsencrypt/cli-1861.history.state.gov.ini"

# where to write log output
log_file="/var/log/letsencrypt/letsencrypt.log"

# installation path
le_path="/opt/letsencrypt"

# start renewal
echo "Starting renewal script..." | tee -a "$log_file"
# the renwal process itself
cd "$config_path" || return
PYTHON_INSTALL_LAYOUT="" $le_path/certbot-auto certonly --config "$config_file" --agree-tos --debug
# restarting the web server
echo "Reloading nginx" | tee -a "$log_file"
nginx -t && service nginx restart | tee -a "$log_file"
exit 0;

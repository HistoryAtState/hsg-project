#!/usr/bin/env bash
cd /home/ec2-user/hsg-project && git pull
/usr/bin/rsync -a /home/ec2-user/hsg-project/deploy/1991/etc/nginx/* /etc/nginx && sudo chown -R root:root /etc/nginx/
sudo /usr/sbin/nginx -t && sudo /sbin/service nginx reload
echo "nginx config updated successfully"

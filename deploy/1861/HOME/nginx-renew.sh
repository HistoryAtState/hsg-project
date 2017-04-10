#!/usr/bin/env bash
cd /home/ec2-user/hsg-project && git pull
/usr/bin/rsync -a /home/ec2-user/hsg-project/deploy/1861/etc/nginx/* /etc/nginx && chown -R root:root /etc/nginx/
/usr/sbin/nginx -t && /sbin/service nginx reload
echo "nginx config updated successfully"

#!/bin/bash
cd /home/ec2-user/hsg-project && git fetch
/usr/bin/rsync -a /home/ec2-user/hsg-project/deploy/1991/etc/nginx/* /etc/nginx && chown -R root:root /etc/nginx/
/usr/sbin/nginx -t && /sbin service nginx reload
echo "nginx config updated successfully"

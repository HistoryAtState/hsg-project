#!/bin/bash
rsync -a /home/ec2-user/nginx/ /etc/nginx
/usr/sbin/nginx -t && /sbin service nginx reload

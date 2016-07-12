## Let’s Encrypt

[Let’s Encrypt] provides free SSL certificates with its own Certificate Authority.

The certificates are valid for three month and have to be renewed in between this period.

To get a certificate it is necessary to install the [Let’s Encrypt] client [certbot]; which is done in the directory `/opt/letsencrypt/`.

## The Renewal Script

The script (`$HOME/letsencrypt/letsencrypt-renew.sh`) will be executed with a crontab task:

~~~shell
sudo crontab -e
~~~

with content

~~~text
30 2 * * 1 $HOME/letsencrypt/letsencrypt-renew.sh >> $HOME/letsencrypt/letsencrypt-renewal.log
~~~

If the validation period comes to its end the script will start the renew process. Through this __the nginx web server will be stopped__; the [certbot] client generates a new certificate and start its own web server to get verified by the [Let’s Encrypt] CA. Afterwards nginx will be started again.

The result is logged to `$HOME/letsencrypt/letsencrypt-renewal.log`.

[Let’s Encrypt]: https://letsencrypt.org/
[certbot]: https://github.com/certbot/certbot

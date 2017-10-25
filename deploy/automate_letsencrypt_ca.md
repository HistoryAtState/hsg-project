## Let’s Encrypt

[Let’s Encrypt] provides free SSL certificates with its own Certificate Authority.

The certificates are valid for three months and have to be renewed in between this period.

To get a certificate it is necessary to install the [Let’s Encrypt] client [certbot]; which is done in the directory `/opt/letsencrypt/`.

### Requirements for using Let's Encrypt with nginx on Amazon Linux

To use the [certbot] script, either `python2.6` or `python2.7` is required.  
Installation info can be found at [certbot.eff.org](https://certbot.eff.org/#centosrhel6-nginx).

We use `python27` with its `virtualenv`:

~~~shell
sudo yum install epel-release python27-pip python27-devel
sudo alternatives --set python /usr/bin/python2.7
sudo pip install --upgrade pip virtualenv
~~~

There is "Experimental Nginx Plugin Support" in the `certbot-nginx` plugin. The instructions can be found in certbot's [Developer Guide](https://certbot.eff.org/docs/contributing.html#running-a-local-copy-of-the-client). Quoting from this guide:

> Running the client in developer mode from your local tree is a little different than running `letsencrypt-auto`. To get set up, do these things once:

~~~shell
git clone https://github.com/certbot/certbot
cd certbot
./letsencrypt-auto-source/letsencrypt-auto --os-packages-only
./tools/venv.sh
~~~

> Then in each shell where you’re working on the client, do:

~~~shell
source ./venv/bin/activate
~~~

> After that, your shell will be using the virtual environment, and you run the client by typing:

~~~shell
certbot
~~~

> Activating a shell in this way makes it easier to run unit tests with `tox` and integration tests, as described below. To reverse this, you can type `deactivate`. More information can be found in the [virtualenv docs](https://virtualenv.pypa.io/).

## Getting the First Certificate

Clone `letsencrypt` and change into the directory.

~~~shell
git clone https://github.com/certbot/certbot /opt/letsencrypt
cd /opt/letsencrypt
~~~

To let `letsencrypt` run its own web server (required to confirm ownership of the domain to the Let's Encrypt CA), we have to stop `nginx`.

~~~shell
service nginx stop
~~~

To start the `letsencrypt` process the first time, run the `letsencrypt-auto` script in the `letsencrypt` directory with debugging enabled for each subdomain. (Change `$SUBDOMAIN` to actual subdomain!)
The certificates will be generated in `/etc/letsencrypt/live/$SUBDOMAIN.history.state.gov/`.

~~~shell
./letsencrypt-auto certonly --rsa-key-size 4096 --agree-tos -d $SUBDOMAIN.history.state.gov --debug
~~~

Write the path in the `nginx.ssl.conf`.

     ssl_certificate      /etc/letsencrypt/live/$SUBDOMAIN.history.state.gov/fullchain.pem;
     ssl_certificate_key  /etc/letsencrypt/live/$SUBDOMAIN.history.state.gov/privkey.pem;

Check the `nginx` config and start the web server again.

~~~shell
nginx -t && service nginx start
~~~

## Renewing the Certificate

The script for renewing the certificate (`$HOME/letsencrypt/letsencrypt-renew.sh`) will be executed with a crontab task:

~~~shell
sudo crontab -e
~~~

with the following content, which runs the script every 14 days at 2:30 a.m.:

~~~text
30 2 */14 * * /home/ec2-user/letsencrypt/letsencrypt-renew.sh
~~~

The `letsencrtypt-renewal.sh` script checks to see if the current certificate will expire in the next 30 days or less. If so, it will initiate the renewal process. The renewal process involves the following steps: (1) __stop the nginx web server__; (2) the [certbot] client will generate a new certificate and start its own web server to get verified by the [Let’s Encrypt] CA; and (3) finally, nginx will be started back up using the renewed certificate. The renewal process is [estimated](https://community.letsencrypt.org/t/how-long-will-it-take-to-get-a-certificate/1200) to take 10s-1m.

The result is logged to `/var/log/letsencrypt/letsencrypt.log`; check it with

`sudo tail -f /var/log/letsencrypt/letsencrypt.log`

or

`sudo tail -f /var/log/letsencrypt/letsencrypt.log.1`

**/var/log/letsencrypt/letsencrypt.log may be empty because the log rotation the script uses.**

## Manual checks

To manually check the expiration date run

`sudo openssl x509 -in "/etc/letsencrypt/live/1861.history.state.gov/fullchain.pem" -text -noout|grep "Not After"`

(or 1991 for the frontend-2)

[Let’s Encrypt]: https://letsencrypt.org/
[certbot]: https://github.com/certbot/certbot

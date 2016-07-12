## Let’s Encrypt

[Let’s Encrypt] provides free SSL certificates with its own Certificate Authority.

The certificates are valid for three month and have to be renewed in between this period.

To get a certificate it is necessary to install the [Let’s Encrypt] client [certbot]; which is done in the directory `/opt/letsencrypt/`.

### Requirements for using with nginx at Amazon Linux

To use the [certbot] script, either `python2.6` or `python2.7` is required.  
Installation info can be found at [certbot.eff.org](https://certbot.eff.org/#centosrhel6-nginx).

For the Frontends we use `python27` with its `virtualenv`:

~~~shell
sudo yum install epel-release python27-pip python27-devel
sudo alternatives --set python /usr/bin/python2.7
sudo pip install --upgrade pip virtualenv
~~~

There is an "Experimental Nginx Plugin Support" with the `certbot-nginx` plugin. The instructions can be found in certbot's [Developer Guide](https://certbot.eff.org/docs/contributing.html#running-a-local-copy-of-the-client).

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

## Getting the First Certificate Step By Step

Clone `letsencrypt` and change into the directory.

~~~shell
git clone https://github.com/certbot/certbot /opt/letsencrypt
cd /opt/letsencrypt
~~~

To let `letsencrypt` run its own web server; stop `nginx`.

~~~shell
service nginx stop
~~~

To start the `letsencrypt` process the first time run the `letsencrypt-auto` script in the `letsencrypt` directory with debugging enabled for each subdomain. (Change `$SUBDOMAIN` to actual subdomain!)
The certificates will be generated in `/etc/letsencrypt/live/$SUBDOMAIN.history.state.gov/`.

~~~shell
./letsencrypt-auto certonly --rsa-key-size 4096 --agree-tos -d $SUBDOMAIN.history.state.gov --debug
~~~

Write the path in the `nginx.ssl.conf`.

     ssl_certificate      /etc/letsencrypt/live/$SUBDOMAIN.history.state.gov/fullchain.pem;
     ssl_certificate_key  /etc/letsencrypt/live/$SUBDOMAIN.history.state.gov/privkey.pem;

Checking the `nginx` config and starting the web server again.

~~~shell
nginx -t && service nginx start
~~~

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

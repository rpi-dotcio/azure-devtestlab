#!/bin/bash
#
# Script to install basic LAMP stack.
#
# NOTE: Intended for use by the Azure DevTest Lab artifact system.
#
set -e

# Update Apt
apt update

# Install Apache2, Mariadb, php, and git
apt install apache2 -y
apt install mariadb-server -y
apt install php php-zip php-curl php-dev php-mysql php-mbstring libapache2-mod-php -y
apt install git -y

# Enable /node/ proxypassed URL
a2enmod proxy proxy_http rewrite headers expires

cat << EOF > /etc/apache2/sites-enabled/000-default.conf
<VirtualHost *:80>
        # The ServerName directive sets the request scheme, hostname and port that
        # the server uses to identify itself. This is used when creating
        # redirection URLs. In the context of virtual hosts, the ServerName
        # specifies what hostname must appear in the request's Host: header to
        # match this virtual host. For the default virtual host (this file) this
        # value is not decisive as it is used as a last resort host regardless.
        # However, you must set it for any further virtual host explicitly.
        #ServerName www.example.com

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html

        # needs modules loaded with 'a2enmod proxy proxy_http rewrite headers expires'
        ProxyRequests Off
        ProxyPreserveHost On
        ProxyVia Full
        ProxyPass /node http://localhost:3000/
        ProxyPassReverse /node http://localhost:3000/

        # Available loglevels: trace8, ..., trace1, debug, info, notice, warn,
        # error, crit, alert, emerg.
        # It is also possible to configure the loglevel for particular
        # modules, e.g.
        #LogLevel info ssl:warn

        ErrorLog ${APACHE_LOG_DIR}/error.log
        CustomLog ${APACHE_LOG_DIR}/access.log combined

</VirtualHost>
EOF


systemctl restart apache2
systemctl restart mariadb

systemctl enable apache2
systemctl enable mariadb

cat << EOF > /var/www/html/checkphp.php
<?php
phpinfo( );
?>
EOF

set +e
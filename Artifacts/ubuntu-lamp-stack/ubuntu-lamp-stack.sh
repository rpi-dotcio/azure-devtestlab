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
apt install git

systemctl restart apache2
systemctl restart maraidb

systemctl enable apache2
systemctl enable mariadb

cat << EOF > /var/www/html/checkphp.php
<?php
phpinfo( );
?>
EOF

set +e
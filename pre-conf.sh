#!/bin/bash

/usr/bin/mysqld_safe &
 sleep 10s

 mysqladmin -u root password mysqlpsswd
 mysqladmin -u root -pmysqlpsswd reload
 mysqladmin -u root -pmysqlpsswd create ushahidi

 echo "GRANT ALL ON ushahidi.* TO ushahidiuser@localhost IDENTIFIED BY 'ushahidipasswd'; flush privileges; " | mysql -u root -pmysqlpsswd

 php5enmod mcrypt
 php5enmod imap
 COOKIE_SALT=`pwgen -c -n -1 32`
 cd /var/www/
 git clone https://github.com/ushahidi/platform.git
 git submodule update --init --recursive
 mv /database.php /var/www/platform/application/config/environments/development/database.php
 curl -sS https://getcomposer.org/installer | php
 mv composer.phar /usr/local/bin/composer
 cd /var/www/platform/
 /var/www/platform/bin/update
 cd /var/www/
 chown -R www-data:www-data /var/www/platform
 mv /var/www/platform/httpdocs/template.htaccess /var/www/platform/httpdocs/.htaccess
 cp platform/application/config/init.php platform/application/config/environments/development/
 sed  -i "s/'index_file'  => FALSE,/'index_file'  => 'index.php',/" platform/application/config/environments/development/init.php
 # Reset the default cookie salt to something unique
 sed -i -e "s/Cookie::\$salt = '.*';/Cookie::\$salt = '$COOKIE_SALT';/" platform/application/bootstrap.php 
 chmod 755 platform/application/cache
 chmod 755 platform/application/logs
 chmod 755 platform/application/media/uploads
 chmod 755 platform/httpdocs/.htaccess
 rm -R /var/www/html
 
  #to fix error relate to ip address of container apache2
  echo "ServerName localhost" | tee /etc/apache2/conf-available/fqdn.conf
  ln -s /etc/apache2/conf-available/fqdn.conf /etc/apache2/conf-enabled/fqdn.conf
 
 a2enmod rewrite
 a2enmod headers


killall mysqld
sleep 10s

#!/bin/bash
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
sudo yum install -y mysql
sudo yum install mysql-client -y

sudo amazon-linux-extras install -y lamp-mariadb10.2-php7.2 php7.2

sudo wget -c http://wordpress.org/latest.tar.gz
sudo tar -xzvf latest.tar.gz
sleep 25
sudo mkdir -p /var/www/html/
sudo rsync -av wordpress/* /var/www/html/
sudo chown -R www-data:www-data /var/www/html/
sudo chmod -R 755 /var/www/html/
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sudo systemctl restart httpd
sleep 25

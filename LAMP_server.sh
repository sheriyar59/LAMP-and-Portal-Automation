#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please run with sudo."
    exit 1
fi
# Function to prompt for sudo password once
# sudo -v

# Basic Setup
echo "Updating and upgrading the system..."
sudo apt update && sudo apt upgrade -y

echo "Installing required packages..."
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql

# Secure MySQL Installation
echo "Securing MySQL installation..."
sudo mysql_secure_installation <<EOF

n
y
y
y
y
EOF

# MySQL Setup # CHANGE THESE ... 
echo "Creating a MySQL database and user..."
DB_NAME="my_database"
DB_USER="my_user"
DB_PASS="my_password"  # Change this to a secure password

sudo mysql -u root -p <<EOF
CREATE DATABASE $DB_NAME;
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
QUIT;
EOF

# Apache Site Setup
DOMAIN="example.com"  # Change to your domain

if [ ! -f /etc/apache2/sites-available/$DOMAIN.conf ]; then
    echo "Creating Apache virtual host for $DOMAIN..."
    sudo tee /etc/apache2/sites-available/$DOMAIN.conf > /dev/null <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    ServerAdmin webmaster@$DOMAIN
    DocumentRoot /var/www/$DOMAIN
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

    # Enable site and restart Apache
    sudo mkdir -p /var/www/$DOMAIN
    sudo a2ensite $DOMAIN.conf
    sudo a2dissite 000-default.conf
    sudo systemctl restart apache2
else
    echo "Virtual host for $DOMAIN already exists. Skipping creation."
fi

# Uncomment if want websecurity 
# Web Security
#echo "Setting up web security..."
#sudo tee -a /etc/apache2/apache2.conf > /dev/null <<EOF

#<Directory /var/www/>
#    Options -Indexes +FollowSymLinks
#    AllowOverride All
#</Directory>

#<Files .env>
#    Order allow,deny
#    Deny from all
#</Files>
#EOF

# Restart Apache to apply changes
sudo systemctl restart apache2

# Un
# Let's Encrypt Setup for Apache
#echo "Installing Certbot for Let's Encrypt..."
#sudo apt install -y certbot python3-certbot-apache

# add your email 
#echo "Obtaining SSL certificates..."
#sudo certbot --apache -d $DOMAIN --agree-tos --non-interactive --email youremail@example.com

echo "LAMP server setup complete!"

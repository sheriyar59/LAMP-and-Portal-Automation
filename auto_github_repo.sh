#!/bin/bash

if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please run with sudo."
    exit 1
fi
# Prompt for sudo upfront
#sudo -v

# Variables
DOMAIN_NAME="hotspot.example.com"
WEB_ROOT="/var/www"
REPO_URL="https://github.com/splash-networks/mikrotik-yt-radius-portal"
ENV_FILE="$WEB_ROOT/$DOMAIN_NAME/.env"
APACHE_CONF_PATH="/etc/apache2/sites-available/$DOMAIN_NAME.conf"
COMPOSER_INSTALL_URL="https://getcomposer.org/installer"

# Keep the sudo session active while the script runs
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Clone the portal repository
echo "Cloning the portal repository..."
sudo git clone $REPO_URL $WEB_ROOT/$DOMAIN_NAME

# Copy .env.example to .env
echo "Setting up environment variables..."
if [ -f "$WEB_ROOT/$DOMAIN_NAME/.env.example" ]; then
  sudo cp "$WEB_ROOT/$DOMAIN_NAME/.env.example" "$ENV_FILE"
  echo "Edit the .env file to configure environment variables."
else
  echo ".env.example not found in the repository."
fi

# Navigate to public folder
cd "$WEB_ROOT/$DOMAIN_NAME/public"

# Install Composer
echo "Installing Composer..."
curl -sS $COMPOSER_INSTALL_URL -o composer-setup.php
sudo php composer-setup.php --install-dir=/usr/local/bin --filename=composer
rm composer-setup.php

# Run Composer install to install dependencies
echo "Running Composer to install dependencies..."
cd "$WEB_ROOT/$DOMAIN_NAME"
sudo php /usr/local/bin/composer install

# Check if Apache Virtual Host file already exists
if [ -f "$APACHE_CONF_PATH" ]; then
    echo "Virtual host configuration already exists for $DOMAIN_NAME. Skipping creation."
else
    echo "Configuring Apache Virtual Host..."
    sudo bash -c "cat > $APACHE_CONF_PATH" <<EOL
<VirtualHost *:80>
    ServerName $DOMAIN_NAME
    DocumentRoot $WEB_ROOT/$DOMAIN_NAME/public

    <Directory $WEB_ROOT/$DOMAIN_NAME/public>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/${DOMAIN_NAME}_error.log
    CustomLog \${APACHE_LOG_DIR}/${DOMAIN_NAME}_access.log combined
</VirtualHost>
EOL

    # Enable site and restart Apache
    echo "Enabling site and restarting Apache..."
    sudo a2ensite $DOMAIN_NAME.conf
    sudo systemctl restart apache2
fi

echo "Setup complete! Please check the configuration and ensure environment variables are set in $ENV_FILE."

#!/bin/bash

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please run with sudo."
    exit 1
fi
# Prompt for sudo upfront
#sudo -v

# Variables
DOMAIN_NAME="hotspot.example.com"
WEB_ROOT="/var/www"
APACHE_CONF_PATH="/etc/apache2/sites-available/$DOMAIN_NAME.conf"

# Keep the sudo session active while the script runs
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Remove the portal directory
echo "Removing portal directory..."
if [ -d "$WEB_ROOT/$DOMAIN_NAME" ]; then
  sudo rm -rf "$WEB_ROOT/$DOMAIN_NAME"
  echo "Removed $WEB_ROOT/$DOMAIN_NAME."
else
  echo "Directory $WEB_ROOT/$DOMAIN_NAME does not exist."
fi

# Remove Apache virtual host configuration
echo "Removing Apache virtual host configuration..."
if [ -f "$APACHE_CONF_PATH" ]; then
  sudo rm "$APACHE_CONF_PATH"
  echo "Removed $APACHE_CONF_PATH."
else
  echo "Apache configuration file $APACHE_CONF_PATH does not exist."
fi

# Disable the site in Apache and restart the service
echo "Disabling site and restarting Apache..."
sudo a2dissite "$DOMAIN_NAME.conf"
sudo systemctl restart apache2

# Remove Composer if installed locally
if [ -f "/usr/local/bin/composer" ]; then
  echo "Removing Composer..."
  sudo rm /usr/local/bin/composer
  echo "Composer removed."
else
  echo "Composer not found in /usr/local/bin."
fi

echo "Cleanup complete!"
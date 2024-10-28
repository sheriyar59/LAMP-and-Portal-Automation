# LAMP and Portal Automation

This repository contains three Bash scripts to automate the setup of a LAMP server, deploy a captive portal, and clean up configurations. The scripts are designed for Ubuntu systems and should be run as root.

## Scripts Included

1. **LAMP_server.sh** - Installs and configures Apache, MySQL, and PHP, and sets up a virtual host.
2. **auto_github_repo.sh** - Clones the captive portal repository, sets up environment variables, installs dependencies with Composer, and configures Apache.
3. **clean_up.sh** - Removes the portal setup and configurations, including Apache virtual host files and Composer, to clean up the server.

## Prerequisites

- Ubuntu or Debian-based system
- `sudo` privileges
- Internet connection
- chmod +x filename

## Usage

Run each script in sequence as follows:

### 1. Set Up the LAMP Server

This script installs Apache, MySQL, and PHP and configures a virtual host.

```bash
sudo bash LAMP_server.sh
```
### 2. Deploy the Captive Portal

```bash
sudo bash auto_github_repo.sh
```
### 3. Cleanup/Undone Configuration if required else dont run it 

```bash
sudo bash clean_up.sh
```


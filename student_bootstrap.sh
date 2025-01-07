#!/bin/bash

# Function to check if the script is run as root
function check_root {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root."
        exit 1
    fi
}

# Create an admin account
function create_admin {
    local ADMIN_USER=$1
    local ADMIN_PASSWORD=$2
    useradd -m -s /bin/bash "$ADMIN_USER"
    echo "$ADMIN_USER:$ADMIN_PASSWORD" | chpasswd
    usermod -aG sudo "$ADMIN_USER"
    echo "Admin account '$ADMIN_USER' created."
}

# Install Twingate
function install_twingate {
    echo "Installing Twingate..."
    wget -qO- https://binaries.twingate.com/linux/setup.sh | bash
    echo "Twingate installed."
}

# Install Wazuh
function install_wazuh {
    echo "Installing Wazuh..."

    # Add Wazuh repository
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
    echo "deb https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list

    # Install Wazuh manager
    apt-get update
    apt-get install -y wazuh-manager

    # Enable and start Wazuh service
    systemctl enable wazuh-manager
    systemctl start wazuh-manager

    echo "Wazuh installed and running."
}

# Main script execution
check_root

# Create two admin accounts
ADMIN1="admin1"
ADMIN1_PASSWORD="Shadow112$" # Change as needed
ADMIN2="student"
ADMIN2_PASSWORD="changemenow" # Change as needed

create_admin "$ADMIN1" "$ADMIN1_PASSWORD"
create_admin "$ADMIN2" "$ADMIN2_PASSWORD"

# Switch to first admin account and install Twingate and Wazuh
su - "$ADMIN1" -c "bash -c '$(declare -f install_twingate install_wazuh); install_twingate; install_wazuh'"

echo "Script execution completed. Two admin accounts created, and Twingate and Wazuh installed for $ADMIN1."

#!/bin/bash

# Function to install dependencies based on Linux distribution
install_dependencies() {
    if ! command -v systemctl &>/dev/null; then
        echo "systemctl is not available. This script requires systemd to manage services."
        exit 1
    fi

    if [ -f /etc/os-release ]; then
        . /etc/os-release
        if [[ $ID == "debian" || $ID == "ubuntu" ]]; then
            apt-get update
            apt-get install -y curl python3 python3-pip
        elif [[ $ID == "centos" || $ID == "rhel" ]]; then
            yum install -y epel-release
            yum install -y curl python3 python3-pip
        elif [[ $ID == "opensuse" || $ID == "sles" ]]; then
            zypper install -y curl python3 python3-pip
        elif [[ $ID == "fedora" ]]; then
            dnf install -y curl python3 python3-pip
        elif [[ $ID == "arch" ]]; then
            pacman -Sy --noconfirm curl python3 python3-pip
        elif [[ $ID == "alpine" ]]; then
            apk add --no-cache curl python3 py3-pip
        elif [[ $ID == "slackware" ]]; then
            slackpkg update
            slackpkg install curl python3
            pip3 install --upgrade pip
        elif [[ $ID == "gentoo" ]]; then
            emerge --sync
            emerge -av dev-lang/python dev-python/pip dev-python/setuptools dev-python/wheel net-misc/curl
        elif [[ $ID == "freebsd" ]]; then
            pkg update
            pkg install -y curl python3 py37-pip
        else
            echo "Unsupported Linux distribution."
            exit 1
        fi
    else
        echo "Unknown Linux distribution."
        exit 1
    fi
}

# Function to download the script and set up the environment
setup_environment() {
    # Create directory if it doesn't exist
    mkdir -p /etc/iic/

    # Download script
    curl -o /etc/iic/receiver.py http://api.iranmonitor.net/receiver.py

    # Download requirements file
    curl -o /etc/iic/requirements.txt http://api.iranmonitor.net/requirements.txt

    # Install required Python packages
    pip3 install -r /etc/iic/requirements.txt
}

# Function to create or update a systemd service
create_or_update_systemd_service() {
    cat <<EOF > /etc/systemd/system/iic.service
[Unit]
Description=IIC Monitoring Service
After=network.target

[Service]
User=root
Group=root
WorkingDirectory=/etc/iic/
ExecStart=/usr/bin/python3 /etc/iic/receiver.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd daemon
    systemctl daemon-reload

    # Restart and enable the service
    systemctl restart iic
    systemctl enable iic
}

# Function to create or update a systemd timer for service restart every 10 minutes
create_or_update_systemd_timer() {
    cat <<EOF > /etc/systemd/system/iic.timer
[Unit]
Description=Run iic every 10 minutes

[Timer]
OnUnitActiveSec=10m
Unit=iic.service

[Install]
WantedBy=timers.target
EOF

    # Reload systemd daemon
    systemctl daemon-reload

    # Restart and enable the timer
    systemctl restart iic.timer
    systemctl enable iic.timer
}

# Main function
main() {
    install_dependencies
    setup_environment
    create_or_update_systemd_service
    create_or_update_systemd_timer
}

main

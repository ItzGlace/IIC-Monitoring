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
            pacman -Sy --noconfirm curl python3 python-pip
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

# Function to create a systemd service
create_systemd_service() {
    cat <<EOF > /etc/systemd/system/iic_monitoring_service.service
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

    # Start and enable the service
    systemctl start iic_monitoring_service
    systemctl enable iic_monitoring_service
}

# Function to create a systemd timer for service restart every 10 minutes
create_systemd_timer() {
    cat <<EOF > /etc/systemd/system/iic_monitoring_service.timer
[Unit]
Description=Run iic_monitoring_service every 10 minutes

[Timer]
OnUnitActiveSec=10m
Unit=iic_monitoring_service.service

[Install]
WantedBy=timers.target
EOF

    # Reload systemd daemon
    systemctl daemon-reload

    # Enable the timer
    systemctl enable iic_monitoring_service.timer
}

# Function to create a systemd timer for daily execution at 5:00 AM
create_daily_timer() {
    cat <<EOF > /etc/systemd/system/iic_daily_timer.timer
[Unit]
Description=Run iic_daily_script at 5:00 AM every day

[Timer]
OnCalendar=*-*-* 05:00:00
Persistent=true
EOF

    # Reload systemd daemon
    systemctl daemon-reload

    # Enable the timer
    systemctl enable iic_daily_timer.timer
}

# Main function
main() {
    install_dependencies
    setup_environment
    create_systemd_service
    create_systemd_timer
    create_daily_timer
}

main

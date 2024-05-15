#!/bin/bash

# Function to print text in royal blue color
print_royal_blue() {
    tput setaf 32  # Set text color to royal blue
    echo "
██╗██╗░█████╗░
██║██║██╔══██╗
██║██║██║░░╚═╝
██║██║██║░░██╗
██║██║╚█████╔╝
╚═╝╚═╝░╚════╝░"
    tput sgr0     # Reset text color
}

# Function to print text in orange color
print_orange() {
    tput setaf 3  # Set text color to orange
    echo "
█▀▄▀█ █▀█ █▄░█ █ ▀█▀ █▀█ █▀█   █▀ █▄█ █▀ ▀█▀ █▀▀ █▀▄▀█
█░▀░█ █▄█ █░▀█ █ ░█░ █▄█ █▀▄   ▄█ ░█░ ▄█ ░█░ ██▄ █░▀░█"
    tput sgr0     # Reset text color
}

# Function to print text in orange and boxed format
print_orange_box() {
    tput setaf 3  # Set text color to orange
    echo "+----------------------------------------------+"
    echo "         $1          "
    echo "+----------------------------------------------+"
    tput sgr0     # Reset text color
}

# Function to install necessary packages
install_packages() {
    print_orange_box "Installing necessary packages..."

    if command -v yum &>/dev/null; then
        sudo yum install -y curl iproute lsof
    elif command -v apk &>/dev/null; then
        sudo apk add --no-cache curl iproute2 lsof
    else
        sudo apt-get update
        sudo apt-get install -y curl iproute2 lsof
    fi

    print_orange_box "Necessary packages installed successfully."
}

# Function to install Apache web server
install_apache() {
    print_orange_box "Installing Apache Web Server..."

    if command -v yum &>/dev/null; then
        sudo yum install -y httpd
    elif command -v apk &>/dev/null; then
        sudo apk add --no-cache apache2
    else
        sudo apt-get update
        sudo apt-get install -y apache2
    fi

    sudo rm -f /var/www/html/index.html
    sudo touch /var/www/html/index.html

    print_orange_box "Apache Web Server installed successfully."
}

# Function to uninstall Apache web server
uninstall_apache() {
    print_orange_box "Uninstalling Apache Web Server..."

    if command -v yum &>/dev/null; then
        sudo yum remove -y httpd
    elif command -v apk &>/dev/null; then
        sudo apk del apache2
    else
        sudo apt-get remove --purge -y apache2
    fi

    echo "Sending IP to the database..."
    ip=$(hostname -I | awk '{print $1}')  # Get IP address
    tput setaf 3  # Set text color to orange
    echo "+----------------------------------------------+"
    curl "http://anubisprwksy.com/iic/remove_from_iic.php?ip=$ip"
    echo "+----------------------------------------------+"
    tput sgr0     # Reset text color

    print_orange_box "Apache Web Server uninstalled successfully."
}

# Function to configure Apache to respond only to specific user-agent
configure_apache() {
    print_orange_box "Configuring Apache to respond only to requests containing header 'user-agent' equals to 'IIC-Node'..."

    # Check if mod_rewrite is enabled, if not, enable it
    if ! sudo a2enmod rewrite; then
        print_orange_box "Failed to enable mod_rewrite. Exiting..."
        exit 1
    fi

    # Create configuration file for user-agent restriction
    echo 'RewriteEngine On' | sudo tee /etc/apache2/conf-available/user-agent.conf
    echo 'RewriteCond %{HTTP_USER_AGENT} !^IIC-Node$' | sudo tee -a /etc/apache2/conf-available/user-agent.conf
    echo 'RewriteRule ^ - [F]' | sudo tee -a /etc/apache2/conf-available/user-agent.conf
    sudo a2enconf user-agent
    sudo systemctl restart apache2
    print_orange_box "Apache is now configured to respond only to requests containing 'user-agent' header equals to 'IIC-Node'."
}

# Function to run Apache web server on specified port
run_apache_on_port() {
    read -p "Enter the port to run the Apache server (default is 500): " port
    port=${port:-500}  # Default port is 500

    # Check if the specified port is available
    if sudo lsof -Pi :$port -sTCP:LISTEN -t >/dev/null; then
        echo "Port $port is already in use. Setting up the server on port 500 instead."
        port=500
    fi

    sudo sed -i "s/Listen 80/Listen $port/g" /etc/apache2/ports.conf
    sudo systemctl restart apache2
    print_orange_box "Apache Web Server is now running on port $port."
    echo "http://$(hostname -I | cut -d' ' -f1):$port"

    echo "Sending server details to the database..."
    ip=$(hostname -I | awk '{print $1}')  # Get IP address
    tput setaf 3  # Set text color to orange
    echo "+----------------------------------------------+"
    curl "http://anubisprwksy.com/iic/add_to_iic.php?ip=$ip&port=$port"
    echo "+----------------------------------------------+"
    tput sgr0     # Reset text color

    print_orange_box "Your server's details are send to iic admins! Your server will soon be reviewed and added to the channel"
}

# Main script starts here

# Welcome message
print_royal_blue
print_orange

# Install necessary packages
install_packages

# Ask user if they want to install or uninstall Apache
read -p "Do you want to install or uninstall Apache Web Server? (1. install/2. uninstall): " action

case $action in
    1)
        install_apache
        configure_apache
        port=$(run_apache_on_port)
        ;;
    2)
        uninstall_apache
        ;;
    *)
        echo "Invalid option. Please choose '1' or '2'."
        ;;
esac

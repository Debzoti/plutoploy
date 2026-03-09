#!/bin/sh

# currently hardcoded for cloudflare only
function check_os() {
    rhel=$(cat /etc/os-release | tr '[:upper:]' '[:lower:]' | (grep -Ec "fedora|centos|rhel|redhat")) >> /dev/null 2>&1
    deb=$(cat /etc/os-release | tr '[:upper:]' '[:lower:]' | (grep -Ec "debian|ubuntu")) >> /dev/null 2>&1
    if [ "$rhel" -ge 1 ]; then
        echo "Supported OS: Fedora, CentOS, RHEL, or Red Hat detected."
    elif [ "$deb" -ge 1 ]; then
        echo "Supported OS: Debian or Ubuntu detected."
    else
        echo "Unsupported OS: RHEL or Debian derivatives are currently supported :( oops"
    fi
}
function check_env() {
    echo "If you wish to change anythig please edit values in ~/bashrc"
    if [ -z "$CLOUDFLARE_EMAIL" ]; then
        read -p "Enter your Cloudflare email: " CLOUDFLARE_EMAIL
        echo "export CLOUDFLARE_EMAIL=$CLOUDFLARE_EMAIL" >> ~/.bashrc
    fi

    if [ -z "$CLOUDFLARE_API_KEY" ]; then
        read -p "Enter your Cloudflare API key: " CLOUDFLARE_API_KEY
        echo "export CLOUDFLARE_API_KEY=$CLOUDFLARE_API_KEY" >> ~/.bashrc
    fi
    source ~/.bashrc
}
function manage_firewall() {
    systemctl enable --now firewalld
    firewall-cmd --permanent --set-default-zone=block
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=2019/tcp
    firewall-cmd --permanent --add-port=6969/tcp #  reserved for backend communication only .. (69  cz it's nicee)
#   incomming traffic :443 ----> firewalld forwards to :8443
#   incomming traffic :80 ----> firewalld forwards to :8443  cz users without sudo access can't use the ports (0-1024)
    firewall-cmd --permanent --add-forward-port=port=443:proto=tcp:toport=8443
    firewall-cmd --permanent --add-forward-port=port=80:proto=tcp:toport=8080
    firewall-cmd --reload
    exit 1
}
function check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root"
        sudo su -c "$0"
    fi
}
function setup_podlet(){

}
function create_quadlet_service(){

}
function install_on_debian() {
    apt update -y && apt upgrade -y >> /dev/null  2>&1 
    systemctl disable --now ufw >>  /dev/null 2>&1
    apt uninstall -y ufw 
    apt install -y wget firewalld fuse-overlayfs slirp4netns podman podman-compose git 
}
function install_on_redhat() {
    dnf update -y  2>&1
    dnf install -y wget firewalld podman podman-compose git fuse-overlayfs slirp4netns
}
function os_setup() {
    check_root
    check_os
    check_env
    if [ "$rhel" -ge 1 ]; then
        install_on_redhat
    elif [ "$deb" -ge 1 ]; then
        install_on_debian
    else
        echo "Unsupported OS: RHEL or Debian derivatives are currently supported :(  kindly refer the manual and build :)" 
    fi
    manage_firewall 
    echo "Setup complete! Please reboot your system."
}
os_setup

#!/bin/sh

# currently hardcoded for cloudflare only
check_os() {
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
check_env() {
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
manage_firewall() {
    systemctl enable firewalld
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
    systemctl start firewalld
    sudo -u "$SUDO_USER" loginctl enable-linger $SUDO_USER
}
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run as root for the first time to setup the environment and install dependencies. after that every thing will be non root :)"
        sudo su -c "$0"
    fi
}
setup_folders(){
    mkdir -p ~/.plutoploy/bin ~/.local/bin  
    echo "export PATH=~/.plutoploy/bin:$PATH" >> ~/.bashrc >> /dev/null 2>&1
    echo "export PATH=~/.local/bin:$PATH" >> ~/.bashrc >> /dev/null 2>&1
    source ~/.bashrc

}
setup_blobs(){
    wget "https://github.com/containers/podlet/releases/download/v0.3.1/podlet-x86_64-unknown-linux-musl.tar.xz" >> /dev/null 2>&1
    tar -xvf podlet-x86_64-unknown-linux-musl.tar.xz >> /dev/null 2>&1
    chmod +x podlet >> /dev/null 2>&1
    mv podlet ~/.local/bin/ >> /dev/null 2>&1
    rm podlet-x86_64-unknown-linux-musl.tar.xz >> /dev/null 2>&1
}
install_on_debian() {
    apt update -y && apt upgrade -y >> /dev/null  2>&1
    systemctl disable --now ufw >>  /dev/null 2>&1
    apt uninstall -y ufw
    apt install -y wget firewalld fuse-overlayfs slirp4netns podman podman-compose
}
install_on_redhat() {
    dnf update -y  2>&1
    dnf install -y wget firewalld podman podman-compose fuse-overlayfs slirp4netns
}
os_setup() {
    check_root
    apt remove -y ufw
    check_env
    if [ "$rhel" -ge 1 ]; then
        install_on_redhat
    elif [ "$deb" -ge 1 ]; then
        install_on_debian
    else
        echo "Unsupported OS: RHEL or Debian derivatives are currently supported :(  kindly refer the manual and build :)"
    fi
    setup_blobs
    manage_firewall
    echo "Setup complete! Please reboot your system."
}
os_setup
setup_folders

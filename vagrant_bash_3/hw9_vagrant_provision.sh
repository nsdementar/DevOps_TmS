#!/bin/bash -e

USER_NAME="hw9"
HOME_DIR="/opt"
ETC_HOSTS="/etc/hosts"
ETC_HOSTS_RECORD="127.0.0.1 myownapp.com"
PASSWORD_AUTH="PasswordAuthentication yes"
PASSWORD_NO_AUTH="PasswordAuthentication no"
SSHD_CONF_PATH="/etc/ssh/sshd_config"
ROOT_LOGIN_ON="PermitRootLogin without-password"
ROOT_LOGIN_OFF="PermitRootLogin no"
PACKAGES="mc vim git"
RESOLV_CONF="/etc/resolv.conf"
DNS_1="8.8.8.8"
DNS_2="1.1.1.1"
MY_APP="myownapp.com"
CREATION_DIR_PATH="/var/log/myownapp"
DEFAULT_GROUP="root"

function add_user {
  echo "Start create user: $USER_NAME"
  sudo useradd -s /bin/bash -d ${HOME_DIR}/${USER_NAME} -m -G wheel ${USER_NAME}
}

function add_user_to_sudoer {
  echo "Add $USER_NAME to sudoer"
  sudo sh -c "echo \"$USER_NAME    ALL=(ALL:ALL) NOPASSWD:ALL\" >> /etc/sudoers"
}

function update_hosts {
  echo "Add $MY_APP in /etc/hosts"
  echo "$ETC_HOSTS_RECORD" >> $ETC_HOSTS
}

function disable_password_connection {
  echo "Disable password connection"
  sudo sed -i -- "s/$PASSWORD_AUTH/$PASSWORD_NO_AUTH/g" $SSHD_CONF_PATH
}

function disable_root_login {
  echo "Disable root login"
  sudo sed -i -- "s/$ROOT_LOGIN_ON/$ROOT_LOGIN_OFF/g" $SSHD_CONF_PATH
}

function install_packages {
  echo "Install packages..."
  sudo yum -y install $PACKAGES &> /dev/null
}

function update_dns {
  echo "update DNS"
  sudo chmod 700 $RESOLV_CONF
  sudo echo "nameserver $DNS_1" > $RESOLV_CONF
  sudo echo "nameserver $DNS_2" >> $RESOLV_CONF
}

function myapp_status {
  echo "Check $MY_APP availability"
  if ping -c 1 $MY_APP &> /dev/null
  then
    echo "    $MY_APP available"
  else
    echo "    $MY_APP unvailable"
    update_hosts
  fi
}

function white_ip {
  echo "Check white IP"
  local ip=`curl -s ifconfig.me`
  echo "    White IP: $ip"
}

function create_dir {
  sudo mkdir $CREATION_DIR_PATH
}

function change_dir_owner {
  echo "Change $CREATION_DIR_PATH owner to $USER_NAME"
  create_dir
  sudo chown -R $USER_NAME:$DEFAULT_GROUP $CREATION_DIR_PATH
}

add_user
add_user_to_sudoer
update_hosts
disable_password_connection
disable_root_login
install_packages
update_dns
myapp_status
white_ip
change_dir_owner

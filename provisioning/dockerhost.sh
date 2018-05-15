#! /usr/bin/bash
#
# Provisioning script for srv010

#----------------------------------------------------------------------------
# Bash settings
#----------------------------------------------------------------------------

# abort on nonzero exitstatus
set -o errexit
# abort on unbound variable
set -o nounset
# don't mask errors in piped commands
set -o pipefail

#----------------------------------------------------------------------------
# Variables
#----------------------------------------------------------------------------

# Location of provisioning scripts and files
export readonly provisioning_scripts="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly provisioning_files="${provisioning_scripts}/files/${HOSTNAME}"

# The name of the user that is going to manage the Docker service
readonly docker_admin=vagrant

#----------------------------------------------------------------------------
# "Imports"
#----------------------------------------------------------------------------

# Utility functions
source ${provisioning_scripts}/util.sh

#----------------------------------------------------------------------------
# Provision server
#----------------------------------------------------------------------------

info "Starting provisioning tasks on ${HOSTNAME}"

# Workaround for an issue where the IP address Vagrant assigns to enp0s8 is
# actually not applied.
systemctl restart network

#---------- Docker ----------------------------------------------------------

info "Installing Docker, Cockpit and utilities"

dnf -y install \
  cockpit \
  cockpit-docker \
  docker \
  docker-compose \
  git \
  nano \
  patch

info "Allow ${docker_admin} to use Docker without sudo"

ensure_group_exists docker
assign_groups "${docker_admin}" docker

info "Enabling services"
systemctl enable docker.service
systemctl enable --now cockpit.socket

info "Starting services"
ensure_service_started docker.service

info "Enabling IP forwarding"

if ! grep -q '^net\.ipv4' /etc/sysctl.conf > /dev/null 2>&1; then
  printf "net.ipv4.ip_forward=1\\n" >> /etc/sysctl.conf
  systemctl restart network
fi

# Run the script that deploys the .Net application
${provisioning_scripts}/deploy_dotnet.sh

# Warning: firewalld interferes with Docker, enabling the firewall will make
# the db container inaccessible.

#info "Configuring firewall"

#ensure_service_started firewalld.service
#firewall-cmd --add-service=cockpit --permanent
#firewall-cmd --add-service=http --permanent
#firewall-cmd --reload


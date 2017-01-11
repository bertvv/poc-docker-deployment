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
export readonly PROVISIONING_SCRIPTS="/vagrant/provisioning/"
# Location of files to be copied to this server
export readonly PROVISIONING_FILES="${PROVISIONING_SCRIPTS}/files/${HOSTNAME}"

# The name of the user that is going to manage the Docker service
readonly docker_admin=vagrant

#----------------------------------------------------------------------------
# "Imports"
#----------------------------------------------------------------------------

# Utility functions
source ${PROVISIONING_SCRIPTS}/util.sh

#----------------------------------------------------------------------------
# Provision server
#----------------------------------------------------------------------------

info "Starting provisioning tasks on ${HOSTNAME}"

# Workaround for an issue where the IP address Vagrant assigns to enp0s8 is
# actually not applied.
systemctl restart network

#---------- Docker ----------------------------------------------------------

info "Installing Docker, Cockpit and utilities"

yum -y install \
  docker \
  docker-compose \
  cockpit \
  cockpit-docker \
  nano \
  vim-enhanced

info "Allow ${docker_admin} to use Docker without sudo"

ensure_group_exists docker
assign_groups "${docker_admin}" docker

info "Enabling services"
systemctl enable docker.service
systemctl enable cockpit.service

info "Starting services"
ensure_service_started docker.service
ensure_service_started cockpit.service

info "Applying firewall rules"
firewall-cmd --permanent --add-port=9090/tcp
firewall-cmd --permanent --add-service=http
firewall-cmd --permanent --add-interface enp0s8
systemctl restart firewalld.service

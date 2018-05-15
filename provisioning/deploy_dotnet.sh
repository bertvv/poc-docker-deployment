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

# Git repository of the .Net application
readonly app_name='10thBeerhallMvcAdv'
readonly repo_url="https://github.com/WebIII/${app_name}.git"
# Directory within the project repository containing the source code
readonly src_dir='Beerhall'
# Root password
readonly db_root_password='LetMeInPLZ!!1!'

# Local installation directory
readonly install_dir='/opt/app'
readonly app_root="${install_dir}/${app_name}"

#----------------------------------------------------------------------------
# "Imports"
#----------------------------------------------------------------------------

# Utility functions
source ${provisioning_scripts}/util.sh

#----------------------------------------------------------------------------
# Script proper
#----------------------------------------------------------------------------

info "Clone .Net project"

if [ ! -d "${app_root}" ]; then
  git clone "${repo_url}" "${app_root}"
  cd "${app_root}"
  patch -p1 < "${provisioning_files}/Program.cs.patch"
else
  info "  -> already cloned"
fi

info "Copying Docker configuration files"

copy_if_different \
  "${provisioning_files}/docker-compose.yml" \
  "${app_root}/${src_dir}/docker-compose.yml"

copy_if_different \
  "${provisioning_files}/Dockerfile" \
  "${app_root}/${src_dir}/Dockerfile"

copy_if_different \
  "${provisioning_files}/appsettings.Production.json" \
  "${app_root}/${src_dir}/appsettings.Production.json"

info "Building and launching container images"

cd "${app_root}/${src_dir}"
docker-compose up --build -d


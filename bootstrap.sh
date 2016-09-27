#!/bin/bash

cd $HOME

###############################################################################
#
# Stage 0: Upgrade the base system and reboot
#
###############################################################################

if [ "$1" = "0" ]; then
  # Update the package list
  sudo apt-get update

  # Perform a full-upgrade, non-intertactively, using defaults for all options
  DEBIAN_FRONTEND=noninteractive sudo apt-get -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" full-upgrade

  # The kernel and other critical software may have been upgraded so we reboot
  # before starting the next stage.
  echo "@reboot sleep 10 && ssh -oStrictHostKeyChecking=no ubuntu@localhost ${HOME}/bootstrap.sh 1 >> ${HOME}/bootstrap.log 2>&1" | crontab -
  sudo reboot
  exit 0
fi

###############################################################################
#
# Stage 1: Install essential packages, then hand-off to the repository's script
#
###############################################################################

if [ "$1" = "1" ]; then
  # Install the packages required to identify and clone the repository
  DEBIAN_FRONTEND=noninteractive sudo apt-get install -q -y \
    build-essential \
    curl \
    git \
    ntp \
    wget

  # Download the instance's user_data and source it
  wget -q -O $HOME/bootstrap.env http://169.254.169.254/latest/user-data
  source $HOME/bootstrap.env

  # Make sure we've accepted github's SSH identity
  ssh -oStrictHostKeyChecking=no git@github.com

  if [ "$GIT_REPO" != "" ]; then
    # A git repository was provided, clone it and continue with the project's
    # bootstrap script.
    project_name=$(echo "${GIT_REPO}" | cut -f 2 -d / | cut -f 1 -d .)
    git clone $GIT_REPO $HOME/$project_name
    echo "@reboot sleep 10 && ssh -oStrictHostKeyChecking=no ubuntu@localhost ${HOME}/$project_name/config/bootstrap.sh >> ${HOME}/bootstrap.log 2>&1" | crontab -
  else
    # No repository, nothing left to do.
    crontab -r
  fi
  sudo reboot
  exit 0
fi

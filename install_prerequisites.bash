#!/bin/bash
set -o errexit

if [ "$EUID" -ne 0 ];
then
  echo "This script should be run as root (or with sudo)."
  exit 1
fi

apt-get update -qq

apt-get install -y puppet librarian-puppet

# Needed to use the Docker upstream apt repositories.
apt-get install -y apt-transport-https

# install pip3 via pypi to avoid https://github.com/ros-infrastructure/buildfarm_deployment/issues/64
apt-get install -y python3-pip
pip3 install -U pip

# config for librarian for more efficient syncronization
librarian-puppet config rsync true --global


# check cron setup (for https://github.com/ros-infrastructure/buildfarm_deployment/issues/187)
printf "Checking %-20s .. " "cron setup"
if [ ! -e /etc/cron.allow ] || [ -e /etc/cron.deny ];
then
  echo -e "WARN  (found 'cron.allow' and/or 'cron.deny')\n"
  echo -e "Warning: Jenkins agent crontab configuration may fail.\n"
else
  echo "OK"
fi

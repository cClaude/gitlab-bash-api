#!/bin/bash
#

GITLAB_PRIVATE_TOKEN=__YOUR_GITLAB_TOCKEN_HERE__
GITLAB_URL_PREFIX=https://gitlab

# Optionnal

# Require to clone using ssh
#GITLAB_CLONE_SSH_PREFIX=git@192.168.10.200

# Require to clone using http/https
#GITLAB_USER=__YOUR_GIT_USER__
#GITLAB_PASSWORD=__YOUR_GIT_USER_PASSWORD__
#GITLAB_CLONE_HTTP_PREFIX="https://${GITLAB_USER}:${GITLAB_PASSWORD}@${GITLAB_URL_PREFIX#"https://"}"

# You can also configure in you ~/.bashrc file
#
# export GITLAB_BASH_API_PATH='__YOUR_PATH_TO/gitlab-bash-api__'
# export GITLAB_BASH_API_CONFIG="${GITLAB_BASH_API_PATH}/my-config"

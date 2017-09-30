#!/bin/bash

#
# Docker configuration
# - Don't need customisation for testing
# - Run setup-configuration.sh to take in account these parameters
#

# Docker configuration
DOCKER_HOSTNAME=gitlab.example.com
DOCKER_NAME=gitlab
DOCKER_HTTP_PORT=80
DOCKER_SSH_PORT=22

# GitLab configuration
DOCKER_GITLAB_HTTP_HOST=localhost
DOCKER_GITLAB_SSH_HOST=localhost

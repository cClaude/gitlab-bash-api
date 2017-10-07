#!/bin/bash

#
# Docker configuration
# - Don't need customisation for testing
# - Run setup-configuration.sh to take in account these parameters
# - If you need special settings you can create a file "my-config.sh"
#   to overwrite values.

# Container version
declare -r DOCKER_GITLAB_CE_VERSION_LATEST=gitlab/gitlab-ce:latest
declare -r DOCKER_GITLAB_CE_VERSION_RC=gitlab/gitlab-ce:rc
declare -r DOCKER_GITLAB_EE_VERSION_LATEST=gitlab/gitlab-ee:latest
declare -r DOCKER_GITLAB_EE_VERSION_RC=gitlab/gitlab-ee:rc

DOCKER_GITLAB_VERSION=${DOCKER_GITLAB_CE_VERSION_RC}
DOCKER_GITLAB_API_VERSION=v4

# Docker configuration
DOCKER_NAME=gitlab
DOCKER_HTTP_PORT=80
DOCKER_SSH_PORT=22

# GitLab configuration
DOCKER_GITLAB_HTTP_HOST=localhost
DOCKER_GITLAB_SSH_HOST=${DOCKER_GITLAB_HTTP_HOST}

DOCKER_GITLAB_USER=root
# You must use this password on first connection
DOCKER_GITLAB_PASSWORD=secret123

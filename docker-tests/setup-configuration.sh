#!/bin/bash

DOCKER_GITLAB_HOME_PATH=$(realpath "$(dirname $(realpath "$0"))")

DOCKER_GITLAB_CONFIGURATION_PATH="${DOCKER_GITLAB_HOME_PATH}/docker-config"
DOCKER_GITLAB_CONFIGURATION_FILE="${DOCKER_GITLAB_CONFIGURATION_PATH}/config.sh"

source "${DOCKER_GITLAB_CONFIGURATION_FILE}"

if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(dirname $(realpath "$0")))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

#
# GitLab configuration
#
GITLAB_BASH_API_CONFIG="${DOCKER_GITLAB_HOME_PATH}/gitlab-bash-api-config-for-docker"
GITLAB_BASH_API_CONFIG_FILE="${GITLAB_BASH_API_CONFIG}/generated-configuration"

echo "#!/bin/bash

# Generated configuration file - do not edit

GITLAB_HOST=${DOCKER_GITLAB_HTTP_HOST}
GITLAB_PORT=${DOCKER_HTTP_PORT}

GITLAB_USER=${DOCKER_GITLAB_USER}
GITLAB_PASSWORD=${DOCKER_GITLAB_PASSWORD}

GITLAB_URL_PREFIX="http://${DOCKER_GITLAB_HTTP_HOST}:${DOCKER_HTTP_PORT}"
GITLAB_CLONE_SSH_PREFIX=git@${DOCKER_GITLAB_SSH_HOST}:${DOCKER_SSH_PORT}

GITLAB_API_VERSION=v4
" > "${GITLAB_BASH_API_CONFIG_FILE}"

#
# gitlab-bash-api configuration
#
BOOTSTRAP_CONFIG_PATH="${DOCKER_GITLAB_HOME_PATH}/generated-config-bootstrap"
BOOTSTRAP_CONFIG_FILE="${BOOTSTRAP_CONFIG_PATH}/init.sh"

mkdir -p "${BOOTSTRAP_CONFIG_PATH}"

echo "#!/bin/bash

export GITLAB_BASH_API_PATH=$(dirname $(dirname $(realpath "$0")))
export GITLAB_BASH_API_CONFIG=${GITLAB_BASH_API_CONFIG}

export DOCKER_GITLAB_CONFIGURATION_FILE="${DOCKER_GITLAB_CONFIGURATION_FILE}"

" >"${BOOTSTRAP_CONFIG_FILE}"

#
# Summerize
#
echo "
Customization store in '${GITLAB_BASH_API_CONFIG_FILE}'

DOCKER_GITLAB_CONFIGURATION_PATH=${DOCKER_GITLAB_CONFIGURATION_PATH}

GITLAB_BASH_API_PATH=${GITLAB_BASH_API_PATH}
GITLAB_BASH_API_CONFIG=${GITLAB_BASH_API_CONFIG}
" >&2

bash generate-private-token.sh


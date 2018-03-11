#!/bin/bash

source "$(realpath "$(dirname "$(realpath "$0")")")/api/gitlab-docker-api.sh"

function generate_gitlab_bash_api_custom_configuration {
  echo "Create/Update '${GITLAB_BASH_API_CONFIG_FILE}'" >&2
  echo "#!/bin/bash
#
# Generated configuration file - do not edit
#
declare -r GITLAB_HOST='${DOCKER_GITLAB_HTTP_HOST}'
declare -r GITLAB_PORT='${DOCKER_HTTP_PORT}'

declare -r GITLAB_USER='${DOCKER_GITLAB_USER}'
declare -r GITLAB_PASSWORD='${DOCKER_GITLAB_PASSWORD}'
declare -r GITLAB_PRIVATE_TOKEN='${DOCKER_GITLAB_PRIVATE_TOKEN}'

declare -r GITLAB_URL_PREFIX='http://${DOCKER_GITLAB_HTTP_HOST}:${DOCKER_HTTP_PORT}'
declare -r GITLAB_CLONE_SSH_PREFIX='git@${DOCKER_GITLAB_SSH_HOST}:${DOCKER_SSH_PORT}'

declare -r GITLAB_API_VERSION='${DOCKER_GITLAB_API_VERSION}'

export GITLAB_HOST
export GITLAB_PORT

export GITLAB_USER
export GITLAB_PASSWORD
export GITLAB_PRIVATE_TOKEN

export GITLAB_URL_PREFIX
export GITLAB_CLONE_SSH_PREFIX

export GITLAB_API_VERSION
" > "${GITLAB_BASH_API_CONFIG_FILE}"
}

function generate_gitlab_docker_custom_configuration {
  echo "Create/Update '${BOOTSTRAP_CONFIG_FILE}'" >&2
  echo "#!/bin/bash
#
# Generated configuration file - do not edit
#
declare -r DOCKER_GITLAB_HOME_PATH='${DOCKER_GITLAB_HOME_PATH}'

declare -r GITLAB_BASH_API_PATH='$(dirname "$(dirname "$(realpath "$0")")")'
declare -r GITLAB_BASH_API_CONFIG='${GITLAB_BASH_API_CONFIG}'

declare -r DOCKER_GITLAB_VERSION='${DOCKER_GITLAB_VERSION}'
declare -r DOCKER_NAME='${DOCKER_NAME}'

declare -r DOCKER_SSH_PORT='${DOCKER_SSH_PORT}'
declare -r DOCKER_HTTP_PORT='${DOCKER_HTTP_PORT}'
declare -r DOCKER_HTTPS_PORT='${DOCKER_HTTPS_PORT}'

declare -r DOCKER_RESTART_MODE='${DOCKER_RESTART_MODE}'

declare -r DOCKER_ETC_VOLUME='${DOCKER_ETC_VOLUME}'
declare -r DOCKER_LOGS_VOLUME='${DOCKER_LOGS_VOLUME}'
declare -r DOCKER_DATA_VOLUME='${DOCKER_DATA_VOLUME}'

declare -r DOCKER_GITLAB_HTTP_HOST='${DOCKER_GITLAB_HTTP_HOST}'
declare -r DOCKER_GITLAB_SSH_HOST='${DOCKER_GITLAB_SSH_HOST}'

declare -r DOCKER_GITLAB_USER='${DOCKER_GITLAB_USER}'
declare -r DOCKER_GITLAB_PASSWORD='${DOCKER_GITLAB_PASSWORD}'
declare -r DOCKER_GITLAB_PRIVATE_TOKEN='${DOCKER_GITLAB_PRIVATE_TOKEN}'

export DOCKER_GITLAB_HOME_PATH

export GITLAB_BASH_API_PATH
export GITLAB_BASH_API_CONFIG

export DOCKER_GITLAB_VERSION
export DOCKER_NAME

export DOCKER_SSH_PORT
export DOCKER_HTTP_PORT
export DOCKER_HTTPS_PORT

export DOCKER_RESTART_MODE

export DOCKER_ETC_VOLUME
export DOCKER_LOGS_VOLUME
export DOCKER_DATA_VOLUME

export DOCKER_GITLAB_HTTP_HOST
export DOCKER_GITLAB_SSH_HOST

export DOCKER_GITLAB_USER
export DOCKER_GITLAB_PASSWORD
export DOCKER_GITLAB_PRIVATE_TOKEN
" >"${BOOTSTRAP_CONFIG_FILE}"
}

source "${DOCKER_GITLAB_CONFIGURATION_FILE}"
if [ ! -f "${DOCKER_GITLAB_CONFIGURATION_FILE}" ] ; then
  echo "*** '${DOCKER_GITLAB_CONFIGURATION_FILE}' is missing." >&2
  exit 1
fi

#
# Take in account custom configuration in my-config.sh
#
if [ -f "${DOCKER_GITLAB_CONFIGURATION_CUSTOM_FILE}" ]; then
  echo "* Found ${DOCKER_GITLAB_CONFIGURATION_CUSTOM_FILE} - override default configuration" >&2
  source "${DOCKER_GITLAB_CONFIGURATION_CUSTOM_FILE}"
else
  echo "* Use default configuration" >&2
fi

#
# Verify setup of gitlab-bash-api
#
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  declare -r GITLAB_BASH_API_PATH="${GITLAB_BASH_API_HOME_PATH}"
fi
if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH
or remove your custom value using
    unset GITLAB_BASH_API_PATH
" >&2
  exit 1
fi

#
# Prepare generated configuration
#
if [ ! -d "${GENERATED_CONFIG_HOME}" ]; then
  echo "* Create folder '${GENERATED_CONFIG_HOME}'" >&2
  mkdir "${GENERATED_CONFIG_HOME}"
fi
if [ ! -d "${GENERATED_CONFIG_HOME}" ]; then
  echo "*** '${GENERATED_CONFIG_HOME}' is missing." >&2
  exit 1
fi

#
# GitLab configuration
#
declare -r GITLAB_BASH_API_CONFIG="${GENERATED_CONFIG_HOME}/gitlab-bash-api"

if [ ! -d "${GITLAB_BASH_API_CONFIG}" ]; then
  echo "* Create folder '${GITLAB_BASH_API_CONFIG}'" >&2
  mkdir "${GITLAB_BASH_API_CONFIG}"
fi

declare -r GITLAB_BASH_API_CONFIG_FILE="${GITLAB_BASH_API_CONFIG}/generated-configuration"

echo 'Prepare customization' >&2
generate_gitlab_bash_api_custom_configuration

#
# gitlab-bash-api configuration
#
declare -r BOOTSTRAP_CONFIG_PATH="${GENERATED_CONFIG_HOME}/docker-config"
declare -r BOOTSTRAP_CONFIG_FILE="${BOOTSTRAP_CONFIG_PATH}/init.sh"

if [ ! -d "${BOOTSTRAP_CONFIG_PATH}" ]; then
  echo "* Create '${BOOTSTRAP_CONFIG_PATH}'" >&2
  mkdir -p "${BOOTSTRAP_CONFIG_PATH}"
fi

generate_gitlab_docker_custom_configuration

#
# Summerize
#
echo "
  GITLAB_BASH_API_PATH=${GITLAB_BASH_API_PATH}
  GITLAB_BASH_API_CONFIG=${GITLAB_BASH_API_CONFIG}
" >&2

if [ -z "${DOCKER_GITLAB_PRIVATE_TOKEN}" ] ; then
  echo "* Warning
  DOCKER_GITLAB_PRIVATE_TOKEN is not yet define.
" >&2

  help_tocken_configuration
fi

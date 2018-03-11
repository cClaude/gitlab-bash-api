#!/bin/bash

function verify_GITLAB_BASH_API_HOME_PATH {
  if [ ! -f "${GITLAB_BASH_API_HOME_PATH}/api/gitlab-bash-api.sh" ] ; then
    echo "*** ERROR: unexpected path for GITLAB_BASH_API_HOME_PATH: '${GITLAB_BASH_API_HOME_PATH}'" >&2
    echo "*** File not found '${GITLAB_BASH_API_HOME_PATH}/api/gitlab-bash-api.sh'" >&2
    exit 1
  fi
}

function verify_GITLAB_DOCKER_TESTS_HOME_PATH {
  if [ ! -f "${GITLAB_DOCKER_TESTS_HOME_PATH}/api/gitlab-docker-api.sh" ] ; then
    echo "*** ERROR: unexpected path for GITLAB_DOCKER_TESTS_HOME_PATH: '${GITLAB_DOCKER_TESTS_HOME_PATH}'" >&2
    echo "*** ERROR: ${GITLAB_DOCKER_TESTS_HOME_PATH}/api/gitlab-docker-api.sh" >&2
    exit 1
  fi

  if [ ! -f "${GITLAB_TESTS_API}" ] ; then
    echo "*** ERROR:file not found GITLAB_TESTS_API: '${GITLAB_TESTS_API}'" >&2
    exit 1
  fi
}

declare GITLAB_BASH_API_HOME_PATH
GITLAB_BASH_API_HOME_PATH=$(realpath "$(dirname "$(dirname "$(realpath "$0")")")")
declare -r GITLAB_BASH_API_HOME_PATH

verify_GITLAB_BASH_API_HOME_PATH

declare GITLAB_DOCKER_TESTS_HOME_PATH
GITLAB_DOCKER_TESTS_HOME_PATH=$(realpath "$(dirname "$(realpath "$0")")")
declare -r GITLAB_DOCKER_TESTS_HOME_PATH
declare -r GITLAB_TESTS_API="${GITLAB_DOCKER_TESTS_HOME_PATH}/api/gitlab-test-api.sh"

verify_GITLAB_DOCKER_TESTS_HOME_PATH

declare -r GENERATED_CONFIG_HOME="${GITLAB_DOCKER_TESTS_HOME_PATH}/generated"

declare -r DOCKER_GITLAB_CONFIGURATION_PATH="${GITLAB_DOCKER_TESTS_HOME_PATH}/docker-config"
declare -r DOCKER_GITLAB_CONFIGURATION_FILE="${DOCKER_GITLAB_CONFIGURATION_PATH}/config.sh"
declare -r DOCKER_GITLAB_CONFIGURATION_CUSTOM_FILE="${DOCKER_GITLAB_CONFIGURATION_PATH}/my-config.sh"

function help_tocken_configuration {
  echo "* Warning
  You need to configure DOCKER_GITLAB_PRIVATE_TOKEN.

  Start GitLab using gitlab.sh script. When GitLab will be started:
  Open http://${DOCKER_GITLAB_HTTP_HOST}:${DOCKER_HTTP_PORT}/profile/personal_access_tokens
  (you need to be connected as ${DOCKER_GITLAB_USER})
" >&2
}

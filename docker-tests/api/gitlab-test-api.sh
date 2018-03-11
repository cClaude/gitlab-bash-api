#!/bin/bash

declare -r GENERATED_CONFIG_HOME_INIT="${GENERATED_CONFIG_HOME}/docker-config/init.sh"
if [ -f "${GENERATED_CONFIG_HOME_INIT}" ] ; then
  source "${GENERATED_CONFIG_HOME_INIT}"
else
  echo "*** ERROR: File not found GENERATED_CONFIG_HOME_INIT='${GENERATED_CONFIG_HOME_INIT}'" >&2
  exit 1
fi

declare -r GITLAB_BASH_API_PATH
declare -r GITLAB_BASH_API_CONFIG


function verify_config {
  if [ "${GITLAB_BASH_API_PATH}" != "${GITLAB_BASH_API_HOME_PATH}" ] ; then
    echo "*** ERROR: GITLAB_BASH_API_PATH is wrong
    * ____found: '${GITLAB_BASH_API_PATH}'
    * _expected: '${GITLAB_BASH_API_HOME_PATH}'
  " >&2
    exit 1
  else
    echo "* Use GITLAB_BASH_API_PATH='${GITLAB_BASH_API_PATH}" >&2
  fi

  local gitlab_bash_api_config_expected="${GENERATED_CONFIG_HOME}/gitlab-bash-api"

  if [ "${GITLAB_BASH_API_CONFIG}" != "${gitlab_bash_api_config_expected}" ] ; then
    echo "*** ERROR: GITLAB_BASH_API_CONFIG is wrong
    * ____found: '${GITLAB_BASH_API_CONFIG}'
    * _expected: '${gitlab_bash_api_config_expected}'
  " >&2
    exit 1
  else
    echo "* Use GITLAB_BASH_API_CONFIG='${GITLAB_BASH_API_CONFIG}" >&2
  fi
}

verify_config

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-project.sh"

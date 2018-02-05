#!/bin/bash

function display_usage {
  echo "Usage: $0
    $0 --uri GL_URI --params
" >&2
  exit 100
}

function main {
  local api_url=
  local api_params=

  while [[ $# -gt 0 ]]; do
    local param="$1"
    shift

    case "${param}" in
    '--uri'|'--url'|'-u')
      api_url="$1"
      shift
      ;;
    '--params'|'-p')
      api_params="$1"
      shift
      ;;
    *)
      # unknown option
      echo "Undefine parameter ${param}" >&2
      display_usage
      ;;
    esac
  done

  if [ -z "${api_url}" ] ; then
    echo "** Missing parameter --uri" >&2
    display_usage
  fi

  gitlab_put "${api_url}" "${api_params}"
}

# Configuration - BEGIN
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname "$(realpath "$0")")
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
# Configuration - END

# Script start here

if [ $# -eq 0 ]; then
  display_usage
fi

main "$@"

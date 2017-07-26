#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/deploy_keys.html
#

# Configuration
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(realpath "$0"))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"

# Script start here
if [ $# -eq 0 ]; then
  echo "Usage: $0 [--all | PROJECT_ID]" >&2
  exit 100
fi

# Parameters
if [ "$1" = "--all" ]; then
  PROJECT_ID=
else
  PROJECT_ID=$1
fi

LIST_KEYS=$(list_deploy_keys_raw "${PROJECT_ID}" '')
echo "${LIST_KEYS}" | jq .

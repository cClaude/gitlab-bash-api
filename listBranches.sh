#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html#list-branches
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
if [[ $# -lt 1 ]] ; then
  echo "Usage: $0 <PROJECT_ID>" >&2
  exit 1
fi

# Parameters
PROJECT_ID=$1

answer=$(gitlab_get "projects/${PROJECT_ID}/repository/branches" "${PARAMS}") || exit 1
LIST_BRANCHES=$(echo "${answer}" | jq .)

echo "${LIST_BRANCHES}"

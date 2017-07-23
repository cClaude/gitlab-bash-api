#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html
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
if [[ $# -ne 1 ]] ; then
  echo "Usage: $0 GROUP_NAME" >&2
  exit 1
fi

# Parameters
GROUP_NAME=$1

#answer=$(gitlab_get "projects" ) || exit 1

PROJECTS_IN_GROUP=$(list_projects_in_group "${GROUP_NAME}") || exit 1
echo "${PROJECTS_IN_GROUP}"

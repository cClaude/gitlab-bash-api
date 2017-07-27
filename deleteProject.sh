#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html#remove-project
#
# Parameters:
#   id	integer/string	yes	The ID or URL-encoded path of the project
#

# Configuration - BEGIN
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(realpath "$0"))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
# Configuration - END

if [[ $# -lt 2 ]] ; then
  echo "Usage: $0 GROUP_NAME PROJECT_NAME" >&2
  echo "Usage: $0 --id PROJECT_ID" >&2
  exit 1
fi

# Parameters
if [ "$1" = "--id" ]; then
  PROJECT_ID=$2

  echo "# delete project: PROJECT_ID=[${PROJECT_ID}]"
else
  GROUP_NAME=$1
  PROJECT_NAME=$2

  PROJECT_ID=$(get_project_id "${GROUP_NAME}" "${PROJECT_NAME}") || exit 1
  echo "# delete project: PROJECT_ID=[${PROJECT_ID}] : GROUP_NAME=[${GROUP_NAME}] - PROJECT_NAME=[${PROJECT_NAME}]"
fi

answer=$(delete_projects_by_id "${PROJECT_ID}") || exit 1

echo "${answer}"

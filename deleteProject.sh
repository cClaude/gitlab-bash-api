#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html#remove-project
#
# Parameters:
#   id	integer/string	yes	The ID or URL-encoded path of the project
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

if [[ $# -lt 2 ]] ; then
  echo "Usage: $0 <GROUP_NAME> <PROJECT_NAME>" >&2
  exit 1
fi

# Parameters
GROUP_NAME=$1
PROJECT_NAME=$2

answer=$(gitlab_get "projects" ) || exit 1
PROJECT_INFO=$(echo "${answer}" | jq -c ".[] | select( .path_with_namespace | contains(\"${GROUP_NAME}/${PROJECT_NAME}\"))")
PROJECT_ID=$(echo "${PROJECT_INFO}" | jq -c ".id")
VALID_PROJECT_ID=$(echo "${PROJECT_ID}" | wc -l)

if [ ${VALID_PROJECT_ID} -ne 1 ] ; then
  echo "*** More than one maching project: ${VALID_PROJECT_ID}"
  exit 200
fi

if [ -z "${PROJECT_ID}" ] ; then
  echo -e "** Project \"${GROUP_NAME}/${PROJECT_NAME}\" does not exist"
  exit 250
fi

echo "# delete project: PROJECT_ID=[${PROJECT_ID}] : GROUP_NAME=[${GROUP_NAME}] - PROJECT_NAME=[${PROJECT_NAME}]"

answer=$(gitlab_delete "projects/${PROJECT_ID}") || exit 1
if [ "${answer}" != "true" ] ; then
  echo "Can not delete project..."
  echo "CURL_URL=${CURL_URL}"
  echo "${CURL_RESULT}"
  exit 300
fi

echo "done"

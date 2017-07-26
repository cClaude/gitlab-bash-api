#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/deploy_keys.html
#

function display_usage {
  echo "Usage: $0 --project-id PROJECT_ID --key-id DEPLOY_KEY_ID" >&2
  exit 100
}

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
  display_usage
fi

# Parameters
PROJECT_ID=
DEPLOY_KEY_ID=
DELETE=false

while [[ $# > 0 ]]
do
param="$1"
shift
case $param in
    -n|--name)
        PROJECT_NAME="$1"
        shift
        ;;
    -i|--project-id)
        PROJECT_ID="$1"
        shift
        ;;
    -k|--key-id)
        DEPLOY_KEY_ID="$1"
        shift
        ;;
    --delete)
        DELETE=true
        ;;
        
    *)
        # unknown option
        echo "Undefine parameter ${param}"
        display_usage
        ;;
esac
done

if [ "${DELETE}" = "true" ] ; then
  answer=$(delete_deploy_keys "${PROJECT_ID}" "${DEPLOY_KEY_ID}" )
else
  answer=$(enable_deploy_keys "${PROJECT_ID}" "${DEPLOY_KEY_ID}" )
fi

echo "${answer}" | jq .

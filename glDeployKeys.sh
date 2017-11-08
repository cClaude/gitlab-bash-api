#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/deploy_keys.html
#
ACTION=''

function display_usage {
  echo "Usage: $0" >&2
  echo "  List all existing deploy keys" >&2
  echo "    $0 (no parameters)" >&2
  echo "  List enabled deploy keys for a project" >&2
  echo "   $0 --project-id PROJECT_ID" >&2
  echo "  Enable a deploy key on a project" >&2
  echo "   $0 --enable --project-id PROJECT_ID --key-id DEPLOY_KEY_ID" >&2
  echo "  Delete  a deploy key on a project" >&2
  echo "   $0 --delete --project-id PROJECT_ID --key-id DEPLOY_KEY_ID" >&2
  exit 100
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

# Parameters
PROJECT_ID=
DEPLOY_KEY_ID=

while [[ $# -gt 0 ]]
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
        set_action 'DELETE'
        ;;
    --enable)
        set_action 'ENABLE'
        ;;
    *)
        # unknown option
        echo "Undefine parameter ${param}"
        display_usage
        ;;
esac
done

case $ACTION in
    DELETE)
        ensure_not_empty_deprecated "PROJECT_ID"
        ensure_not_empty_deprecated "DEPLOY_KEY_ID"
        answer=$(delete_deploy_keys "${PROJECT_ID}" "${DEPLOY_KEY_ID}" )
        ;;
    ENABLE)
        ensure_not_empty_deprecated "PROJECT_ID"
        ensure_not_empty_deprecated "DEPLOY_KEY_ID"
        answer=$(enable_deploy_keys "${PROJECT_ID}" "${DEPLOY_KEY_ID}" )
        ;;
    *)
        # List
        ensure_empty_deprecated "DEPLOY_KEY_ID"
        answer=$(list_deploy_keys_raw "${PROJECT_ID}" '')
        ;;
esac

echo "${answer}" | jq .


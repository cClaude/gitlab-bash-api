#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ee/api/groups.html
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
  echo "Usage: $0 --all | --name GROUP_NAME | GROUP_ID" >&2
  exit 100
fi

# Parameters
case "$1" in
  --all)
      GROUP_ID=
      GROUP_NAME=
      ;;

  --name)
      GROUP_ID=
      GROUP_NAME=$2
      ;;

  *)
      GROUP_ID=$1
      GROUP_NAME=
esac

answer=$(list_groups_raw "${GROUP_ID}" '')

if [ -z "${GROUP_NAME}" ] ; then
  echo "${answer}" | jq .
else 
  echo "${answer}" | jq "[.[] | select(.name==\"${GROUP_NAME}\")]"
fi

# List all id
# ./listGroups.sh --all | jq '. [] | .id'

# List name and id
# ./listGroups.sh --all | jq '[ . [] | { name: .name, id: .id } ]'

# Number of group visible for current user
# ./listGroups.sh --all | jq '. | length'

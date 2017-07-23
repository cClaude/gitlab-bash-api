#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ee/api/groups.html#new-group
#
# Parameters:
#   name (required) - The name of the group
#   path (required) - The path of the group
#   description (optional) - The group's description
#
#   lfs_enabled (optional) - Enable/disable Large File Storage (LFS) for the projects in this group
#   membership_lock (optional, boolean) - Prevent adding new members to project membership within this group
#   parent_id (optional) - The parent group id for creating nested group.
#   request_access_enabled (optional) - Allow users to request member access.
#   share_with_group_lock (optional, boolean) - Prevent sharing a project with another group within this group
#   shared_runners_minutes_limit (optional) - (admin-only) Pipeline minutes quota for this group
#   visibility (optional) - The group's visibility. Can be private, internal, or public.
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
  echo "Usage: $0 GROUP_PATH ['GROUP_NAME' ['GROUP_DESCRIPTION']]" >&2
  exit 1
fi

# Parameters
GROUP_PATH=$1
GROUP_NAME=$2

if [ ! -z "$3" ] ; then
  GROUP_DESCRIPTION="$3"
else
  GROUP_DESCRIPTION="${GITLAB_GROUP_DESCRIPTION}"
fi

if [ -z "${GROUP_NAME}" ] ; then
  GROUP_NAME="${GROUP_PATH}"
fi

echo "Create group GROUP_PATH=[${GROUP_PATH}]/GROUP_NAME=[${GROUP_NAME}] - GROUP_DESCRIPTION=[${GROUP_DESCRIPTION}]"

PARAMS="path=${GROUP_PATH}"

ENCODED=$(urlencode "${GROUP_NAME}")
PARAMS+="&name=${ENCODED}"

ENCODED=$(urlencode "${GROUP_DESCRIPTION}")
PARAMS+="&description=${ENCODED}"

PARAMS+="&lfs_enabled=${GITLAB_GROUP_LFS_ENABLED}"
PARAMS+="&membership_lock=${GITLAB_GROUP_MEMBERSHIP_LOCK}"
PARAMS+="&request_access_enabled=${GITLAB_GROUP_REQUEST_ACCESS_ENABLED}"
PARAMS+="&share_with_group_lock=${GITLAB_GROUP_SHARE_WITH_GROUP_LOCK}"
PARAMS+="&visibility=${GITLAB_GROUP_VISIBILITY}"

#echo "PARAMS=${PARAMS}"

answer=$(gitlab_post "groups" "${PARAMS}") || exit 1
GROUP_ID=$(echo "${answer}" | jq .id)

if [ "${GROUP_ID}" = "null" ] ; then
  echo "*** GROUP_NAME=[${GROUP_NAME}] not created - already exist ?" >&2
  echo "${answer}" >&2
  exit 200
fi

echo "GROUP_ID=${GROUP_ID}"

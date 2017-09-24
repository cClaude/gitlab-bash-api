#!/bin/bash
#
# API Documentation:
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
function create_project_from_params {
  local group_path=$1
  local group_name=$2
  local group_description=$3

  echo "Create group GROUP_PATH=[${group_path}]/GROUP_NAME=[${group_name}] - GROUP_DESCRIPTION=[${group_description}]"

  answer=$(create_group 'path' "${group_path}" \
    'name' "${group_name}" \
    'description' "${group_description}" \
    'lfs_enabled' "${GITLAB_DEFAULT_GROUP_LFS_ENABLED}" \
    'membership_lock' "${GITLAB_DEFAULT_GROUP_MEMBERSHIP_LOCK}" \
    'request_access_enabled' "${GITLAB_DEFAULT_GROUP_REQUEST_ACCESS_ENABLED}" \
    'share_with_group_lock' "${GITLAB_DEFAULT_GROUP_SHARE_WITH_GROUP_LOCK}" \
    'visibility' "${GITLAB_DEFAULT_GROUP_VISIBILITY}")

  local group_id=$(echo "${answer}" | jq .id)

  if [ "${group_id}" = "null" ] ; then
    echo "*** GROUP_NAME=[${GROUP_NAME}] not created - already exist ?" >&2
    echo "${answer}" >&2
    exit 200
  fi

  echo "GROUP_ID=${group_id}"
}

function main {
  if [[ $# -lt 1 ]] ; then
    echo "Usage: $0 GROUP_PATH ['GROUP_NAME' ['GROUP_DESCRIPTION']]" >&2
    exit 1
  fi

  # Parameters
  local group_path=$1
  local group_name=$2
  local group_description=

  if [ ! -z "$3" ] ; then
    group_description="$3"
  else
   group_description="${GITLAB_DEFAULT_GROUP_DESCRIPTION}"
  fi

  if [ -z "${group_name}" ] ; then
    group_name="${group_path}"
  fi

 create_project_from_params "${group_path}" "${group_name}" "${group_description}"
}

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
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-group.sh"

# Script start here
main "$@"


#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ee/api/users.html#users-api
#
# Parameters:
#   name (required) - The name of the group
#   path (required) - The path of the group
#   description (optional) - The group's description
#   membership_lock (optional, boolean) - Prevent adding new members to project membership within this group
#   share_with_group_lock (optional, boolean) - Prevent sharing a project with another group within this group
#   visibility (optional) - The group's visibility. Can be private, internal, or public.
#   lfs_enabled (optional) - Enable/disable Large File Storage (LFS) for the projects in this group
#   request_access_enabled (optional) - Allow users to request member access.
#   parent_id (optional) - The parent group id for creating nested group.
#   shared_runners_minutes_limit (optional) - (admin-only) Pipeline minutes quota for this group
#

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

# Script start here
if [ $# -eq 0 ]; then
  echo "*** $0 [--all | USER_NAME]" >&2
  exit 100
fi

# Parameters
if [ "$1" = "--all" ]; then
  PARAMS=
else
  PARAMS="username=$1"
fi

answer=$(gitlab_get "users" "${PARAMS}") || exit 1
USER_LIST=$(echo "${answer}" | jq .)

echo "${USER_LIST}"

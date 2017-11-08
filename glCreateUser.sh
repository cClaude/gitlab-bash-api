#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ee/api/users.html#user-creation
#
# Parameters:
#   email (required) - Email
#   password (optional) - Password
#   reset_password (optional) - Send user password reset link - true or false(default)
#   username (required) - Username
#   name (required) - Name
#
#   skype (optional) - Skype ID
#   linkedin (optional) - LinkedIn
#   twitter (optional) - Twitter account
#   website_url (optional) - Website URL
#   organization (optional) - Organization name
#   projects_limit (optional) - Number of projects user can create
#   extern_uid (optional) - External UID
#   provider (optional) - External provider name
#   bio (optional) - User's biography
#   location (optional) - User's location
#   admin (optional) - User is admin - true or false (default)
#   can_create_group (optional) - User can create groups - true or false
#   confirm (optional) - Require confirmation - true (default) or false
#   external (optional) - Flags the user as external - true or false(default)
#   shared_runners_minutes_limit (optional) - Pipeline minutes quota for this user
#   avatar (optional) - Image file for user's avatar#
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
if [[ $# -lt 3 ]] ; then
  echo "Usage: $0 USER_NAME 'USER_FULLNAME' 'USER_EMAIL'" >&2
  exit 1
fi

# Parameters

USER_NAME=$1
USER_FULLNAME=$2
USER_EMAIL=$3

echo "create user: USER_NAME=[${USER_NAME}] USER_FULLNAME=[${USER_FULLNAME}] - USER_EMAIL=[${USER_EMAIL}]"

# Build paramters
PARAMS="email=${USER_EMAIL}"
PARAMS+="&username=${USER_NAME}"

ENCODED=$(urlencode "${USER_FULLNAME}")
PARAMS+="&name=${ENCODED}"

PARAMS+="&password=${GITLAB_USER_INITIAL_PASSWORD}"

PARAMS+="&admin=${GITLAB_USER_IS_ADMIN}"
PARAMS+="&can_create_group=${GITLAB_USER_CAN_CREATE_GROUP}"
PARAMS+="&confirm=${GITLAB_USER_CONFIRM}"
PARAMS+="&projects_limit=${GITLAB_USER_PROJECTS_LIMIT}"
PARAMS+="&reset_password=${GITLAB_USER_RESET_PASSWORD}"
PARAMS+="&shared_runners_minutes_limit=${GITLAB_USER_SHARED_RUNNERS_MINUTES_LIMIT}"

#echo "PARAMS:${PARAMS}"

answer=$(gitlab_post "users" "${PARAMS}") || exit 1
USER_ID=$(echo "${answer}" | jq .id)

if [ "${USER_ID}" = "null" ] ; then
  echo "*** USER_NAME=[${USER_NAME}] not created - already exist ?" >&2
  echo "${answer}" >&2
  exit 100
fi

echo "${USER_ID}"

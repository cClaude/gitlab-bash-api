#!/bin/bash

# Configuration - BEGIN
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(dirname $(realpath "$0")))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
# Configuration - END

# Script start here
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-project.sh"

edit_project 353 test-id353 \
    description 'my test description' \
    shared_runners_enabled 'false' \
    request_access_enabled false \
    public_builds false

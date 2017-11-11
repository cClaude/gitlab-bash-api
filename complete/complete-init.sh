#!/bin/bash

if [ -z "${GITLAB_BASH_API_PATH}" ]; then
  GITLAB_BASH_API_PATH=$(dirname "$(dirname "$(realpath "$0")")")
elif [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "*** Bad value GITLAB_BASH_API_PATH=${GITLAB_BASH_API_PATH}" >&2
  echo "Try to fix using current file name" >&2

  GITLAB_BASH_API_PATH=$(dirname "$(dirname "$(realpath "$0")")")
fi

if [ -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "
Now run
  export GITLAB_BASH_API_PATH=${GITLAB_BASH_API_PATH}

  source '${GITLAB_BASH_API_PATH}/complete/_gl_common'
  source '${GITLAB_BASH_API_PATH}/complete/_glGroups'
  source '${GITLAB_BASH_API_PATH}/complete/_glProjects'
"
else
  echo "*** Bad value GITLAB_BASH_API_PATH=${GITLAB_BASH_API_PATH}"
fi

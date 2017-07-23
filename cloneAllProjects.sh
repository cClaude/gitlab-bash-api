#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html
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
# Parameters
case "$1" in
  http)
      URL_TYPE="http"
      ;;

  ssh)
      URL_TYPE="ssh"
      ;;

  *)
      echo $"Usage: $0 http|ssh" >&2
      exit 1
esac

PROJECT_URLS=$(get_project_urls | sort) || exit 1

for u in ${PROJECT_URLS}; do
  PROJECT_URL=$u

  GROUP_FOLDER=$( echo "${PROJECT_URL}"  | rev | cut -b5- | cut -d'/' -f2 | cut -d'/' -f1 | cut -d':' -f1 | rev )

  mkdir -p "${GROUP_FOLDER}"
  pushd "${GROUP_FOLDER}"
  echo "${GROUP_FOLDER} - ${PROJECT_URL}"
  git clone "${PROJECT_URL}"
  popd >/dev/null
done

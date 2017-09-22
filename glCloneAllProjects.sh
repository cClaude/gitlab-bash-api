#!/bin/bash

#
# Clone all projets for user in current folder
#

function get_all_projects_path_with_namespace {
  local project_paths=$(list_projects_compact '' '' | jq -r '.[] | .path_with_namespace' ) || exit 401

  echo "${project_paths}" | sort
}

function get_prefix_url_from_params {
  local prefix_url=

  if [ "${URL_TYPE}" = "http" ] ; then
    if [ -z "${GITLAB_CLONE_HTTP_PREFIX}" ] ; then
        echo "*** GITLAB_CLONE_HTTP_PREFIX is not define" >&2
        exit 1
    fi

    #local begin=$(echo "${GITLAB_CLONE_HTTP_PREFIX}" | cut -d'/' -f1)
    #local end=$(echo "${GITLAB_CLONE_HTTP_PREFIX}" | cut -d'/' -f3-)

    #prefix_url=${begin}//${GITLAB_USER}@${end}/
    prefix_url="${GITLAB_CLONE_HTTP_PREFIX}/"
  else
    if [ -z "${GITLAB_CLONE_SSH_PREFIX}" ] ; then
      echo "*** GITLAB_CLONE_SSH_PREFIX is not define" >&2
      exit 1
    fi
    prefix_url="${GITLAB_CLONE_HTTP_PREFIX}:"
  fi

  echo "${prefix_url}"
}

function git_clone {
  local project_url=$1

  echo "clone ${project_url}"
  git clone ${BARE} ${project_url}
  echo "clone $?"
}

function do_clone_from_params {
  local prefix_url=$(get_prefix_url_from_params) || exit $?
  local project_paths=$(get_all_projects_path_with_namespace) || exit $?

  mkdir -p "${ROOT_OUTPUT_DIRECTORY}"
  pushd "${ROOT_OUTPUT_DIRECTORY}"

  for project_path in ${project_paths}; do
    local group_folder=$(echo "${project_path}" | cut -d'/' -f1)

    echo "# '${group_folder}' <- '${project_path}'"

    mkdir -p "${group_folder}"
    pushd "${group_folder}"

    git_clone "${prefix_url}${project_path}.git"

    popd >/dev/null
  done

  popd >/dev/null
}

function display_http_helper {
  local user=

  if [ -z "${GITLAB_USER}" ] ; then
    user='<GITLAB_USER>'
  else
    user="${GITLAB_USER}"
  fi

  echo "When using http you probably whant to use credential helper cache:" >&2
  echo "  git config --global credential.helper 'cache --timeout 3600'" >&2
  echo "  git config --global credential.${GITLAB_CLONE_HTTP_PREFIX} ${user}" >&2
  echo "or credential helper cache:" >&2
  echo "  git config --global credential.helper store" >&2
  echo "  git config --global credential.${GITLAB_CLONE_HTTP_PREFIX} ${user}" >&2
}

function display_usage {
  echo "Usage: $0 --http|--ssh [--destination <ROOT_OUTPUT_DIRECTORY>]" >&2
  exit 1
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

# Script start here
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-project.sh"

# Parameters
BARE=
URL_TYPE=
ROOT_OUTPUT_DIRECTORY=.

while [[ $# > 0 ]]
do
param="$1"
shift
case "${param}" in
  --bare)
      BARE="--bare"
      ;;
  -d|--destination)
      ROOT_OUTPUT_DIRECTORY="$1"
      shift
      ;;
  --http)
      ensure_empty URL_TYPE
      URL_TYPE="http"
      ;;
  --ssh)
      ensure_empty URL_TYPE
      URL_TYPE="ssh"
      ;;
  *)
      # unknown option
      echo "Undefine parameter ${param}" >&2
      display_usage
      ;;
esac
done

if [ -z "${URL_TYPE}" ] ; then
  echo "** Missing parameter --http or --ssh" >&2
  display_usage
fi

if [ "${URL_TYPE}" = "http" ] ; then
  display_http_helper
fi

do_clone_from_params || exit $?

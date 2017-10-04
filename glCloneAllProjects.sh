#!/bin/bash

function display_usage {
  echo "Clone all projects by groups

Usage: $0
  $0 --http [--bare] [--destination <ROOT_OUTPUT_DIRECTORY>]
  $0 --ssh [--bare] [--destination <ROOT_OUTPUT_DIRECTORY>]
  " >&2
  exit 1
}

function get_prefix_url {
  local clone_type=$1

  local prefix_url=

  case "${clone_type}" in
    http)
      if [ -z "${GITLAB_CLONE_HTTP_PREFIX}" ] ; then
        echo "*** GITLAB_CLONE_HTTP_PREFIX is not define" >&2
        exit 1
      fi

      prefix_url="${GITLAB_CLONE_HTTP_PREFIX}/"
      ;;
    ssh)
      if [ -z "${GITLAB_CLONE_SSH_PREFIX}" ] ; then
        echo "*** GITLAB_CLONE_SSH_PREFIX is not define" >&2
        exit 1
      fi

      prefix_url="${GITLAB_CLONE_SSH_PREFIX}:"
      ;;
    *)
      echo "Unkown clone_type: '${clone_type}'"
      exit 1
      ;;
  esac

  echo "${prefix_url}"
}

function git_clone {
  local project_url=$1
  local p_bare=$2

  if [ ! $# -eq 2 ]; then
    echo "* git_clone: Expecting 2 parameters found $# : '$@'" >&2
    exit 1
  fi

  echo "clone ${project_url}"
  git clone ${p_bare} ${project_url}
  echo "clone $?"
}

function clone_all_projects {
  local url_type=$1
  local bare=$2
  local root_output_directory=$3

  if [ ! $# -eq 3 ]; then
    echo "* clone_all_projects: Expecting 3 parameters found $# : '$@'" >&2
    exit 1
  fi

  local prefix_url=$(get_prefix_url "${url_type}") || exit $?

  if [ -z "${prefix_url}" ]; then
    echo "*** Error when computing clone URL" >&2
    exit 1
  fi

  local project_paths=$(get_all_projects_path_with_namespace) || exit $?

  mkdir -p "${root_output_directory}"
  pushd "${root_output_directory}"

  for project_path in ${project_paths}; do
    local group_folder=$(echo "${project_path}" | cut -d'/' -f1)

    echo "# '${group_folder}' <- '${project_path}'"

    mkdir -p "${group_folder}"
    pushd "${group_folder}"

    git_clone "${bare}" "${prefix_url}${project_path}.git"

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

function main {
  local url_type=
  local bare=
  local root_output_directory=.

  while [[ $# > 0 ]]; do
    local param="$1"
    shift

    case "${param}" in
    --bare)
      bare="--bare"
      ;;
    -d|--destination)
      root_output_directory="$1"
      shift
      ;;
    --http)
      ensure_empty_deprecated url_type
      url_type="http"
      ;;
    --ssh)
      ensure_empty_deprecated url_type
      url_type="ssh"
      ;;
    *)
      # unknown option
      echo "Undefine parameter ${param}" >&2
      display_usage
      ;;
    esac
  done

  if [ -z "${url_type}" ] ; then
    echo "** Missing parameter --http or --ssh" >&2
    display_usage
  fi

  if [ "${url_type}" = "http" ] ; then
    display_http_helper
  fi

  clone_all_projects "${url_type}" "${bare}" "${root_output_directory}"
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

main "$@"

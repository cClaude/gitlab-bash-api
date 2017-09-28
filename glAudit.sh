#!/bin/bash

function display_usage {
  echo "Usage: $0
  Audit full gitlab bash on current credentials
    $0 --directory AUDIT_DESTINATION_FOLDER
" >&2
  exit 100
}

function mk_relative_link {
  local target=$1
  local link_name=$2

  if [ -z "${target}" ]; then
    echo "*** mk_relative_link: target value is missing" >&2
    exit 1
  fi
  if [ -z "${link_name}" ]; then
    echo "*** mk_relative_link: link_name value is missing" >&2
    exit 1
  fi

  if [ -f "${link_name}" ]; then
    rm "${link_name}" # avoid link resolution
  fi

  local relative_target=$(realpath  --no-symlinks --relative-to="$(dirname "${link_name}")" "${target}")

  # echo "relative_target='${relative_target}' link_name='${link_name}' target=${target}" >&2

  ln -s --force "${relative_target}" "${link_name}"
}

function build_audit_folder {
  local audit_folder=$1
  local file_type=$2

  if [ -z "${audit_folder}" ]; then
    echo "*** build_audit_folder: audit_folder value is missing" >&2
    exit 1
  fi
  if [ -z "${file_type}" ]; then
    echo "*** build_audit_folder: file_type value is missing" >&2
    exit 1
  fi

  local folder="${audit_folder}/${file_type}"

  if [ ! -d "${folder}" ]; then
    mkdir -p "${folder}" || exit $?
  fi

  echo "${folder}"
}

function build_audit_file {
  local audit_folder=$1
  local file_type=$2
  local file_name=$3

  if [ -z "${audit_folder}" ]; then
    echo "*** build_audit_file: audit_folder value is missing" >&2
    exit 1
  fi
  if [ -z "${file_type}" ]; then
    echo "*** build_audit_file: file_type value is missing" >&2
    exit 1
  fi
  if [ -z "${file_name}" ]; then
    echo "*** build_audit_file: file_name value is missing" >&2
    exit 1
  fi

  local file="$(build_audit_folder "${audit_folder}" "${file_type}")/${file_name}.json"
  local parent=$(dirname "${file}")

  if [ ! -d "${parent}" ]; then
    mkdir "${parent}"
  fi

  echo "${file}"
}

function get_group_ids {
  "${GITLAB_BASH_API_PATH}/glGroups.sh" --all --list-id || exit 1
}

function get_project_ids {
  "${GITLAB_BASH_API_PATH}/glProjects.sh" --all --list-id || exit 1
}

function get_group_config_by_id {
  local group_id=$1

  if [ -z "${GITLAB_DEFAULT_AUDIT_FOR_GROUP}" ]; then
    echo "* GITLAB_DEFAULT_AUDIT_FOR_GROUP is not define" >&2
    exit 1
  fi

  # "${GITLAB_BASH_API_PATH}/glGroups.sh" --config --id "${group_id}" \
  #   | jq ". | { ${GITLAB_DEFAULT_AUDIT_FOR_GROUP} }"
  show_group_config "${group_id}" \
    | jq ". | { ${GITLAB_DEFAULT_AUDIT_FOR_GROUP} }"
}

function get_project_config_by_id {
  local project_id=$1

  if [ -z "${GITLAB_DEFAULT_AUDIT_FOR_PROJECT}" ]; then
    echo "* GITLAB_DEFAULT_AUDIT_FOR_PROJECT is not define" >&2
    exit 1
  fi

  "${GITLAB_BASH_API_PATH}/glProjects.sh" --config --id "${project_id}" \
    | jq ". | select(.[].id=${project_id}) | .[0] | { ${GITLAB_DEFAULT_AUDIT_FOR_PROJECT} }"
}

function audit_groups_configuration {
  local audit_folder=$1

  local group_ids=$(get_group_ids)

  for group_id in ${group_ids}; do
    local group_config=$(get_group_config_by_id "${group_id}")
    local group_path=$(echo "${group_config}" | jq -r '. .path')

    if [ -z "${group_path}" ]; then
      echo "*** Error: can not retrieve configuration for group '${group_id}'" >&2
    else
      local audit_file=$(build_audit_file "${audit_folder}" 'groups_by_id' "${group_id}")
      local path_link=$(build_audit_file "${audit_folder}" 'groups_by_path' "${group_path}")

      echo "* audit group ${group_id} / ${group_path}" >&2
      # echo "* audit group ${group_id} / ${group_path} -> ${audit_file}" >&2

      echo "${group_config}" > "${audit_file}"

      mk_relative_link "${audit_file}" "${path_link}"
    fi
  done
}

function audit_projects_configuration {
  local audit_folder=$1

  local project_ids=$(get_project_ids)

  for project_id in ${project_ids}; do
    local project_config=$(get_project_config_by_id "${project_id}")
    local project_path=$(echo "${project_config}" | jq -r '.path')
    local project_fullpath=$(echo "${project_config}" | jq -r '.path_with_namespace')

    if [ -z "${project_path}" ]; then
      echo "*** Error: can not retrieve configuration for project '${project_id}'" >&2
    else
      local audit_file=$(build_audit_file "${audit_folder}" 'projects_by_id' "${project_id}")
      local path_link=$(build_audit_file "${audit_folder}" 'projects_by_path' "${project_path}")
      local fullpath_link=$(build_audit_file "${audit_folder}" 'projects_by_path_with_namespace' "${project_fullpath}")

      echo "* audit project ${project_id} / ${project_path}" >&2
      # echo "* audit project ${project_id} / ${project_path} / ${project_fullpath} -> ${audit_file}" >&2

      echo "${project_config}" > "${audit_file}"

      mk_relative_link "${audit_file}" "${path_link}"
      mk_relative_link "${audit_file}" "${fullpath_link}"
    fi
  done
}

function do_audit {
  local audit_folder_home=$1

  #
  audit_groups_configuration "${audit_folder_home}" || exit 1
  #
  audit_projects_configuration "${audit_folder_home}" || exit 1

  #audit_users_configuration ? "${audit_folder_home}" || exit 1
  #audit_merge_request ? "${audit_folder_home}" || exit 1
  #audit_merge_request_configuration ? "${audit_folder_home}" || exit 1
  #audit_merge_request ? "${audit_folder_home}" || exit 1
}

function main {
  local audit_folder_home=

  while [[ $# > 0 ]]; do
    param="$1"
    shift

    case "${param}" in
      -d|--directory)
        audit_folder_home="$1"
        shift
        ;;
      *)
        # unknown option
        echo "Unknown parameter ${param}" >&2
        display_usage
        ;;
    esac
  done

  if [ -z "${audit_folder_home}" ]; then
    display_usage
  else
    do_audit "${audit_folder_home}"
  fi
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
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-group.sh"
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-project.sh"

main $@

#!/bin/bash

function display_usage {
  echo "Usage: $0
  Get projects configuration
    $0 --config [--compact] --id PROJECT_ID
    $0 --config [--compact] --group_path GROUP_PATH
    $0 --config [--compact] --all
    $0 --config [--compact] --path PROJECT_PATH
  List projects names
    $0 --list-name --id PROJECT_ID
    $0 --list-name --group_path GROUP_PATH (could return more than one entry)
    $0 --list-name --all
    $0 --list-name --path PROJECT_PATH (could return more than one entry)
  List projects ids
    $0 --list-id --id PROJECT_ID
    $0 --list-id --group_path GROUP_PATH (could return more than one entry)
    $0 --list-id --all
    $0 --list-id --path PROJECT_PATH
  Create project
    $0 --create --group_path GROUP_PATH
  Delete a project
    $0 --delete --group_path GROUP_PATH --path PROJECT_PATH
    $0 --delete --id PROJECT_ID
" >&2
  exit 100
}

function show_projects_config_handle_params {
  local param_raw_display=$1
  local param_all=$2
  local param_project_id=$3
  local param_group_path=$4
  local param_project_path=$5

  if [ ! $# -eq 5 ]; then
    echo "* show_projects_config_handle_params: Expecting 5 parameters found $# : '$@'" >&2
    exit 1
  fi

  ensure_boolean "${param_raw_display}" 'param_raw_display' || exit 1
  ensure_boolean "${param_all}" 'param_all' || exit 1

  #DEBUG echo "### show_project_config '$1' - '$2' - '$3' - '$4' - '$5'" >&2

  # handle project id !!!!
  local answer=$(show_project_config "${param_raw_display}" "${param_project_id}") || exit 1

  local jq_filter=

  if [ "${param_raw_display}" = "true" ] ; then
    if [ ! -z "${param_group_path}" ]; then
      jq_filter="[.[] | select(.namespace.path==\"${param_group_path}\")]"
    elif [ ! -z "${param_project_path}" ]; then
      jq_filter="[.[] | select(.path==\"${param_project_path}\")]"
    elif [ "${param_all}" = "true" ] ; then
      jq_filter='.'
    elif [ ! -z "${param_project_id}" ] ; then
      jq_filter='.'
    else
      echo "Missing PROJECT_ID, GROUP_PATH, PROJECT_NAME or ALL parameter" >&2
      display_usage
    fi
  else
    if [ ! -z "${param_group_path}" ]; then
      jq_filter="[.[] | select(.group_path==\"${param_group_path}\")]"
    elif [ ! -z "${param_project_path}" ]; then
      jq_filter="[.[] | select(.project_path==\"${param_project_path}\")]"
    elif [  "${param_all}" = "true" ] ; then
      jq_filter='.'
    elif [ ! -z "${param_project_id}" ] ; then
      jq_filter='.'
    else
      echo "Missing PROJECT_ID, GROUP_PATH, PROJECT_NAME or ALL parameter" >&2
      display_usage
    fi
  fi

  local result=$(echo "${answer}" |jq "${jq_filter}" ) || exit 1
  local size=$(echo "${result}" |jq '. | length' ) || exit 1

  if [ $size -eq 0 ] ; then
    echo "* No project available." >&2
  fi

  echo "${result}"
}

function list_projects_names_handle_params {
  local param_raw_display=$1

  local answer=$(show_projects_config_handle_params "$@")

  local jq_filter=

  if [ "${param_raw_display}" = "true" ] ; then
    jq_filter='.[] | .name'
  else
    jq_filter='.[] | .project_name'
  fi

  echo "${answer}" | jq -r "${jq_filter}"
}

function list_projects_ids_handle_params {
  local param_raw_display=$1

  local answer=$(show_projects_config_handle_params "$@")

  local jq_filter=

  if [ "${param_raw_display}" = "true" ] ; then
    jq_filter='.[] | .id'
  else
    jq_filter='.[] | .project_id'
  fi

  echo "${answer}" >answer.json

  echo "${answer}" | jq -r "${jq_filter}"
}

function delete_project_handle_params {
  local param_project_id=$1
  local param_group_name=$2
  local param_project_name=$3

  local project_id=

  if [ -z "${param_project_id}" ]; then
    ensure_not_empty 'param_group_name'
    ensure_not_empty 'param_project_name'

    project_id=$(get_project_id "${param_group_name}" "${param_project_name}") || exit 1
  else
    project_id=${param_project_id}
  fi

  delete_project "${project_id}"
  exit $?
}

function main {
  local param_project_id=
  local param_project_path=
  local param_group_path=
  local param_raw_display=true
  local param_all=false
  local action=

  while [[ $# > 0 ]]; do
    local param="$1"
    shift

    case "${param}" in
      -a|--all)
        param_all=true
        ;;
      --compact)
        param_raw_display=false
        ;;
      --config)
        ensure_empty action
        action=showConfigAction
        ;;
      --delete)
        ensure_empty action
        action=deleteAction
        ;;
      -g|--group-path)
        param_group_path="$1"
        shift
        ;;
      -i|--id)
        param_project_id="$1"
        shift
        ;;
      --list-name)
        ensure_empty action
        action=listNamesAction
        ;;
      --list-id)
        ensure_empty action
        action=listIdsAction
        ;;
      -p|--path|--project-path)
        param_project_path="$1"
        shift
        ;;
      *)
        # unknown option
        echo "Undefine parameter ${param}" >&2
        display_usage
        ;;
    esac
  done

  case "${action}" in
    deleteAction)
        delete_project_handle_params "${param_project_id}" "${param_group_path}" "${param_project_path}"
        ;;
    listNamesAction)
        list_projects_names_handle_params "${param_raw_display}" "${param_all}" "${param_project_id}" "${param_group_path}" "${param_project_path}"
        ;;
    listIdsAction)
        list_projects_ids_handle_params "${param_raw_display}" "${param_all}" "${param_project_id}" "${param_group_path}" "${param_project_path}"
        ;;
    showConfigAction)
        show_projects_config_handle_params "${param_raw_display}" "${param_all}" "${param_project_id}" "${param_group_path}" "${param_project_path}"
        ;;
    *)
        # unknown option
        echo "Missing --config, --list-name, --list-id, --edit or --delete * ${action}" >&2
        display_usage
        ;;
  esac
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

if [ $# -eq 0 ]; then
  display_usage
fi

main "$@"


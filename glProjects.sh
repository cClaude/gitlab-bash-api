#!/bin/bash

function display_usage {
  echo "Usage: $0
  Get projects configuration
    $0 --config [--compact] --name PROJECT_NAME
    $0 --config [--compact] --id PROJECT_ID
    $0 --config [--compact] --group GROUP_NAME
    $0 --config [--compact] --all
  List projects names
    $0 --list-name --name PROJECT_NAME (could return more than one entry)
    $0 --list-name --id PROJECT_ID
    $0 --list-name --group GROUP_NAME (could return more than one entry)
    $0 --list-name --all
  List projects ids
    $0 --list-id --name PROJECT_NAME
    $0 --list-id --id PROJECT_ID
    $0 --list-id --group GROUP_NAME (could return more than one entry)
    $0 --list-id --all
  Delete a project
    $0 --delete --group GROUP_NAME --name PROJECT_NAME
    $0 --delete --id PROJECT_ID
" >&2
  exit 100
}

function show_projects_config_handle_params {
  local param_raw_display=$1
  local param_all=$2
  local param_project_id=$3
  local param_group_name=$4
  local param_project_name=$5

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
    if [ ! -z "${param_group_name}" ]; then
      jq_filter="[.[] | select(.namespace.name==\"${param_group_name}\")]"
    elif [ ! -z "${param_project_name}" ]; then
      jq_filter="[.[] | select(.name==\"${param_project_name}\")]"
    elif [ "${param_all}" = "true" ] ; then
      jq_filter="."
    elif [ ! -z "${param_project_id}" ] ; then
      jq_filter="."
    else
      echo "Missing PROJECT_ID, GROUP_NAME, PROJECT_NAME or ALL parameter" >&2
      exit 1
    fi
  else
    if [ ! -z "${param_group_name}" ]; then
      jq_filter="[.[] | select(.group_name==\"${param_group_name}\")]"
    elif [ ! -z "${param_project_name}" ]; then
      jq_filter="[.[] | select(.project_name==\"${param_project_name}\")]"
    elif [  "${param_all}" = "true" ] ; then
      jq_filter="."
    elif [ ! -z "${param_project_id}" ] ; then
      jq_filter="."
    else
      echo "Missing PROJECT_ID, GROUP_NAME, PROJECT_NAME or ALL parameter" >&2
      exit 1
    fi
  fi

  local result=$(echo "${answer}" |jq "${jq_filter}" ) || exit 1
  local size=$(echo "${result}" |jq '. | length' ) || exit 1

  if [ $size -eq 0 ] ; then
    echo "No project available." >&2
    exit 1
  fi

  #echo "jq_filter=${jq_filter}" >&2
  #echo "size=${size}" >&2
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
  local param_project_name=
  local param_group_name=
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
        param_all=false
        ;;
      --config)
        ensure_empty action
        action=showConfigAction
        ;;
      --delete)
        ensure_empty action
        action=deleteAction
        ;;
      -g|--group)
        param_group_name="$1"
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
      -n|--name)
        param_project_name="$1"
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
        delete_project_handle_params "${param_project_id}" "${param_group_name}" "${param_project_name}"
        ;;
    listNamesAction)
        list_projects_names_handle_params "${param_raw_display}" "${param_all}" "${param_project_id}" "${param_group_name}" "${param_project_name}"
        ;;
    listIdsAction)
        list_projects_ids_handle_params "${param_raw_display}" "${param_all}" "${param_project_id}" "${param_group_name}" "${param_project_name}"
        ;;
    showConfigAction)
        show_projects_config_handle_params "${param_raw_display}" "${param_all}" "${param_project_id}" "${param_group_name}" "${param_project_name}"
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


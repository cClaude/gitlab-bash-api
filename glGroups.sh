#!/bin/bash

function display_usage {
  echo "Usage: $0
  Get groups configuration
    $0 --config --name GROUP_NAME
    $0 --config --id GROUP_ID
    $0 --config --all
  List groups names
    $0 --list-name --name GROUP_NAME
    $0 --list-name --id GROUP_ID
    $0 --list-name --all
  List groups ids
    $0 --list-id --name GROUP_NAME
    $0 --list-id --id GROUP_ID
    $0 --list-id --all
  Edit group configuration
    $0 --edit --id GROUP_ID --name GROUP_NAME --path GROUP_PATH \\
       --description GROUP_DESCRIPTION --visibility  private|internal|public \\
       --lfs_enabled true|false --request_access_enabled true|false
  Delete a group
    $0 --delete --name GROUP_NAME
    $0 --delete --id GROUP_ID
" >&2
  exit 100
}

function delete_group_handle_params {
  local group_id=

  if [ -z "${GROUP_ID}" ]; then
    ensure_not_empty "GROUP_NAME"
    group_id=$(get_group_id "${GROUP_NAME}") || exit 1
  else
    group_id=${GROUP_ID}
  fi

  delete_group "${group_id}"
  exit $?
}

function list_groups_names_handle_params {
  local group_name_or_id_or_empty="${GROUP_ID}"

  if [ -z "${group_name_or_id_or_empty}" ]; then
    group_name_or_id_or_empty="${GROUP_NAME}"
  fi

  local result=$(list_groups "${group_name_or_id_or_empty}" '')

  if [ -z "${group_name_or_id_or_empty}" ]; then
    echo "${result}" | jq '. [] | .name'
  else
    echo "${result}" | jq '. | .name'
  fi
}

function list_groups_ids_handle_params {
  local group_name_or_id_or_empty="${GROUP_ID}"

  if [ -z "${group_name_or_id_or_empty}" ]; then
    group_name_or_id_or_empty="${GROUP_NAME}"
  fi

  local result=$(list_groups "${group_name_or_id_or_empty}" '')

  if [ -z "${group_name_or_id_or_empty}" ]; then
    echo "${result}" | jq '. [] | .id'
  else
    echo "${result}" | jq '. | .id'
  fi
}

function show_group_config_handle_params {
  local group_name_or_id_or_empty="${GROUP_ID}"

  if [ -z "${group_name_or_id_or_empty}" ]; then
    group_name_or_id_or_empty="${GROUP_NAME}"
  fi

  local result=$(show_group_config "${group_name_or_id_or_empty}")

  echo "${result}" | jq .
}

function main {
  local param=
  local action=

  while [[ $# > 0 ]]; do
    param="$1"
    shift

    case "${param}" in
      -a|--all)
        P_ALL=true
        ;;
      --config)
        ensure_empty action
        action=showConfigAction
        ;;
      --delete)
        ensure_empty action
        action=deleteAction
        ;;
      --description)
        GROUP_DESCRIPTION="$1"
        shift
        ;;
      --edit)
        ensure_empty action
        action=editAction
        ;;
      -i|--id)
        GROUP_ID="$1"
        shift
        ;;
      --lfs_enabled)
        LFS_ENABLED="$1"
        shift

        ensure_boolean "${LFS_ENABLED}" '--lfs_enabled'
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
        GROUP_NAME="$1"
        shift
        ;;
      --path)
        GROUP_PATH="$1"
        shift
        ;;
      --request_access_enabled)
        REQUEST_ACCESS_ENABLED="$1"
        shift

        ensure_boolean "${REQUEST_ACCESS_ENABLED}" '--request_access_enabled'
        ;;
      --visibility)
        GROUP_VISIBILITY="$1"
        shift

        case "${GROUP_VISIBILITY}" in
           private|internal|public)
             ;;
           *)
             echo "Illegal value '${GROUP_VISIBILITY}'. --visibility should be private, internal or public." >&2
             display_usage
             ;;
        esac
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
        delete_group_handle_params
        ;;
    editAction)
        ensure_not_empty GROUP_ID
        ensure_not_empty GROUP_NAME
        ensure_not_empty GROUP_PATH
        ensure_not_empty GROUP_VISIBILITY

        edit_group "${GROUP_ID}" "${GROUP_NAME}" "${GROUP_PATH}" "${GROUP_DESCRIPTION}" "${GROUP_VISIBILITY}" "${LFS_ENABLED}" "${REQUEST_ACCESS_ENABLED}" | jq .
        ;;
    listNamesAction)
        list_groups_names_handle_params
        ;;
    listIdsAction)
        list_groups_ids_handle_params
        ;;
    showConfigAction)
        show_group_config_handle_params
        ;;
    *)
        # unknown option
        echo "Missing --config, --list-name, --list-id or --delete" >&2
        echo "Unexpected value for action: '${action}'" >&2
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
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-group.sh"

if [ $# -eq 0 ]; then
  display_usage
fi

# Parameters
GROUP_ID=
GROUP_NAME=
GROUP_PATH=
GROUP_DESCRIPTION=
GROUP_VISIBILITY=
LFS_ENABLED=
REQUEST_ACCESS_ENABLED=
P_ALL=false

main $@

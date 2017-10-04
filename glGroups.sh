#!/bin/bash

function display_usage {
  echo "Usage: $0
  Get groups configuration
    $0 --config --path GROUP_PATH
    $0 --config --id GROUP_ID
    $0 --config --all
  List groups paths
    $0 --list-path --path GROUP_PATH
    $0 --list-path --id GROUP_ID
    $0 --list-path --all
  List groups ids
    $0 --list-id --path GROUP_PATH
    $0 --list-id --id GROUP_ID
    $0 --list-id --all
  Create group
    $0 --create --path GROUP_PATH
        [--name GROUP_NAME] \\
        [--description GROUP_DESCRIPTION] \\
        [--lfs_enabled true|false] \\
        [--membership_lock true|false] \\
        [--request_access_enabled true|false] \\
        [--share_with_group_lock true|false]] \\
        [--visibility  private|internal|public]
  Edit group configuration
    $0 --edit --id GROUP_ID --name GROUP_NAME \\
        --path GROUP_PATH \\
        [--description GROUP_DESCRIPTION] \\
        [--visibility  private|internal|public] \\
        [--lfs_enabled true|false] \\
        [--request_access_enabled true|false]
  Delete a group
    $0 --delete --id GROUP_ID
" >&2
  exit 100
}

function create_group_handle_params {
  local param_group_path=$1
  local param_group_name=$2
  local param_group_description=$3
  local param_group_lfs_enabled=$4
  local param_group_membership_lock=$5
  local param_group_request_access_enabled=$6
  local param_group_share_with_group_lock=$7
  local param_group_visibility=$8

  if [ -z "${param_group_name}" ]; then
    param_group_name="${param_group_path}"
  fi
  if [ -z "${param_group_description}" ]; then
    param_group_description="${GITLAB_DEFAULT_GROUP_DESCRIPTION}"
  fi
  if [ -z "${param_group_lfs_enabled}" ]; then
    param_group_lfs_enabled="${GITLAB_DEFAULT_GROUP_LFS_ENABLED}"
  fi
  if [ -z "${param_group_membership_lock}" ]; then
    param_group_membership_lock="${GITLAB_DEFAULT_GROUP_MEMBERSHIP_LOCK}"
  fi
  if [ -z "${param_group_request_access_enabled}" ]; then
    param_group_request_access_enabled="${GITLAB_DEFAULT_GROUP_REQUEST_ACCESS_ENABLED}"
  fi
  if [ -z "${param_group_share_with_group_lock}" ]; then
    param_group_share_with_group_lock="${GITLAB_DEFAULT_GROUP_SHARE_WITH_GROUP_LOCK}"
  fi
  if [ -z "${param_group_visibility}" ]; then
    param_group_visibility="${GITLAB_DEFAULT_GROUP_VISIBILITY}"
  fi

  create_group 'path' "${param_group_path}" \
    'name' "${param_group_name}" \
    'description' "${param_group_description}" \
    'lfs_enabled' "${param_group_lfs_enabled}" \
    'membership_lock' "${param_group_membership_lock}" \
    'request_access_enabled' "${param_group_request_access_enabled}" \
    'share_with_group_lock' "${param_group_share_with_group_lock}" \
    'visibility' "${param_group_visibility}"
}

function get_group_path_or_id_or_empty {
  local p_all_group=$1
  local p_group_id=$2
  local p_group_path=$3

  local group_path_or_id_or_empty="${p_group_id}"

  if [ -z "${group_path_or_id_or_empty}" ]; then
    group_path_or_id_or_empty="${p_group_path}"
  fi

  if [ -z "${group_path_or_id_or_empty}" ]; then
    if [ ! "${p_all_group}" = true ]; then
      echo "** Missing --id, --path or --all" >&2
      exit 1
    fi
  fi

  echo "${group_path_or_id_or_empty}"
}

function list_groups_paths_handle_params {
  local group_path_or_id_or_empty=$(get_group_path_or_id_or_empty "$@") || exit $?
  local jq_filter=

  if [ -z "${group_path_or_id_or_empty}" ]; then
    jq_filter='. [] | .path'
  else
    jq_filter='. | .path'
  fi

  local result=$(list_groups "${group_path_or_id_or_empty}" '')
  local error_message=$(getErrorMessage "${result}")
  if [ -z "${error_message}" ]; then
    if [ ! "${result}" = 'null' ]; then
      echo "${result}" | jq -r "${jq_filter}"
    fi
  else
    echo "* Warning: '${error_message}' while list_groups '${group_path_or_id_or_empty}'" >&2
  fi
}

function list_groups_ids_handle_params {
  local group_path_or_id_or_empty=$(get_group_path_or_id_or_empty "$@")
  local jq_filter=

  if [ -z "${group_path_or_id_or_empty}" ]; then
    jq_filter='. [] | .id'
  else
    jq_filter='. | .id'
  fi

  local result=$(list_groups "${group_path_or_id_or_empty}" '')
  local error_message=$(getErrorMessage "${result}")
  if [ -z "${error_message}" ]; then
    if [ ! "${result}" = 'null' ]; then
      echo "${result}" | jq -r "${jq_filter}"
    fi
  else
    echo "* Warning: '${error_message}' while list_groups '${group_path_or_id_or_empty}'" >&2
  fi
}

function show_group_config_handle_params {
  local group_path_or_id_or_empty=$(get_group_path_or_id_or_empty "$@") || exit $1

  show_group_config "${group_path_or_id_or_empty}" | jq .
}

function main {
  local param=
  local param_all_groups=false
  local param_group_description=
  local param_group_description_define=false
  local param_group_id=
  local param_group_lfs_enabled=
  local param_group_membership_lock=
  local param_group_name=
  local param_group_path=
  local param_group_request_access_enabled=
  local param_group_share_with_group_lock=
  local param_group_visibility=
  local action=

  while [[ $# > 0 ]]; do
    param="$1"
    shift

    case "${param}" in
      -a|--all)
        param_all_groups=true
        ;;
      --config)
        ensure_empty_deprecated action
        action=showConfigAction
        ;;
      --create)
        ensure_empty_deprecated action
        action=createAction
        ;;
      --delete)
        ensure_empty_deprecated action
        action=deleteAction
        ;;
      --description)
        param_group_description="$1"
        param_group_description_define=true
        shift
        ;;
      --edit)
        ensure_empty_deprecated action
        action=editAction
        ;;
      -i|--id)
        param_group_id="$1"
        shift
        ;;
      --lfs_enabled)
        param_group_lfs_enabled="$1"
        shift

        ensure_boolean "${param_group_lfs_enabled}" '--lfs_enabled'
        ;;
      --list-path)
        ensure_empty_deprecated action
        action=listPathsAction
        ;;
      --list-id)
        ensure_empty_deprecated action
        action=listIdsAction
        ;;
      --membership_lock)
        param_group_membership_lock="$1"
        shift

        ensure_boolean "${param_group_membership_lock}" '--membership_lock'
        ;;
      -n|--name)
        param_group_name="$1"
        shift
        ;;
      --path)
        param_group_path="$1"
        shift
        ;;
      --request_access_enabled)
        param_group_request_access_enabled="$1"
        shift

        ensure_boolean "${param_group_request_access_enabled}" '--request_access_enabled'
        ;;
      --share_with_group_lock)
        param_group_share_with_group_lock="$1"
        shift

        ensure_boolean "${param_group_share_with_group_lock}" '--share_with_group_lock'
        ;;
      --visibility)
        param_group_visibility="$1"
        shift

        case "${param_group_visibility}" in
           private|internal|public)
             ;;
           *)
             echo "Illegal value '${param_group_visibility}'. --visibility should be private, internal or public." >&2
             display_usage
             ;;
        esac
        ;;
      *)
        # unknown option
        echo "Unknown parameter ${param}" >&2
        display_usage
        ;;
    esac
  done

  case "${action}" in
    createAction)
        ensure_not_empty_deprecated param_group_path

        create_group_handle_params "${param_group_path}" "${param_group_name}" "${param_group_description}" \
          "${param_group_lfs_enabled}" "${param_group_membership_lock}" "${param_group_request_access_enabled}" \
          "${param_group_share_with_group_lock}" "${param_group_visibility}" \
          | jq .
        ;;
    deleteAction)
        ensure_not_empty_deprecated param_group_id
        delete_group "${param_group_id}" \
          | jq .
        ;;
    editAction)
        ensure_not_empty_deprecated param_group_id
        ensure_not_empty_deprecated param_group_name
        ensure_not_empty_deprecated param_group_path
        ensure_not_empty_deprecated param_group_visibility

        edit_group "${param_group_id}" "${param_group_name}" "${param_group_path}" \
          "${param_group_description_define}" "${param_group_description}" \
          "${param_group_visibility}" "${param_group_lfs_enabled}" "${param_group_request_access_enabled}" \
          | jq .
        ;;
    listPathsAction)
        list_groups_paths_handle_params "${param_all_groups}" "${param_group_id}" "${param_group_path}"
        ;;
    listIdsAction)
        list_groups_ids_handle_params "${param_all_groups}" "${param_group_id}" "${param_group_path}"
        ;;
    showConfigAction)
        show_group_config_handle_params "${param_all_groups}" "${param_group_id}" "${param_group_path}"
        ;;
    *)
        # unknown option
        echo "Missing --config, --list-name, --list-id, --edit or --delete" >&2
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

main "$@"

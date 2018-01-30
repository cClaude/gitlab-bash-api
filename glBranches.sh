#!/bin/bash

function display_usage {
  echo "Usage: $0
  Get branches configuration
    $0 --config --id PROJECT_ID [ --name BRANCH_NAME]
" >&2
  exit 100
}

function main {
  local action=
  local project_id=
  local branch_name=

  while [[ $# -gt 0 ]]; do
    param="$1"
    shift

    case "${param}" in
      --config)
        ensure_empty action
        action=showConfigAction
        ;;
      --create)
        ensure_empty action
        action=createAction
        ;;
      --delete)
        ensure_empty action
        action=deleteAction
        ;;
      --edit)
        ensure_empty action
        action=editAction
        ;;
      -i|--id|--project-id)
        project_id="$1"
        shift
        ;;
      --list-path)
        ensure_empty action
        action=listPathsAction
        ;;
      --list-id)
        ensure_empty action
        action=listIdsAction
        ;;
      --membership_lock)
        param_group_membership_lock="$1"
        shift

        ensure_boolean "${param_group_membership_lock}" '--membership_lock'
        ;;
      -n|--name)
        branch_name="$1"
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
        ensure_not_empty param_group_path

        create_group_handle_params "${param_group_path}" "${param_group_name}" "${param_group_description}" \
          "${param_group_lfs_enabled}" "${param_group_membership_lock}" "${param_group_request_access_enabled}" \
          "${param_group_share_with_group_lock}" "${param_group_visibility}" \
          | jq .
        ;;
    deleteAction)
        ensure_not_empty param_group_id
        delete_group "${param_group_id}" \
          | jq .
        ;;
    editAction)
        ensure_not_empty param_group_id
        ensure_not_empty param_group_name
        ensure_not_empty param_group_path
        ensure_not_empty param_group_visibility

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
        list_branches "${project_id}" "${branch_name}" | jq .
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
  GITLAB_BASH_API_PATH=$(dirname "$(realpath "$0")")
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
# Configuration - END

# Script start here
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-branch.sh"

if [ $# -eq 0 ]; then
  display_usage
fi

main "$@"

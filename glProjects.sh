#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html#get-single-project
#
function display_usage {
  echo "Usage: $0" >&2
  echo "  Get projects configuration" >&2
  echo "    $0 --config [--compact] --name PROJECT_NAME" >&2
  echo "    $0 --config [--compact] --id PROJECT_ID" >&2
  echo "    $0 --config [--compact] --group GROUP_NAME" >&2
  echo "    $0 --config [--compact] --all" >&2
  echo "  List projects names" >&2
  echo "    $0 --list-name --name PROJECT_NAME (could return more than one entry)" >&2
  echo "    $0 --list-name --id PROJECT_ID" >&2
  echo "    $0 --list-name --group GROUP_NAME (could return more than one entry)" >&2
  echo "    $0 --list-name --all" >&2
  echo "  List projects ids" >&2
  echo "    $0 --list-id --name PROJECT_NAME" >&2
  echo "    $0 --list-id --id PROJECT_ID" >&2
  echo "    $0 --list-id --group GROUP_NAME (could return more than one entry)" >&2
  echo "    $0 --list-id --all" >&2
  echo "  Delete a project" >&2
  echo "    $0 --delete --group GROUP_NAME --name PROJECT_NAME" >&2
  echo "    $0 --delete --id PROJECT_ID" >&2
  exit 100
}

function delete_project {
  local project_id=$1
  local answer=

  echo "# delete project: PROJECT_ID=[${project_id}]" >&2

  answer=$(delete_projects_by_id "${project_id}") || exit 1

  echo "${answer}"
}

function is_project_could_by_identify {
  local result=true
  
  if [ -z "${PROJECT_NAME}" ]; then
    if [ -z "${PROJECT_ID}" ]; then
      if [ -z "${GROUP_NAME}" ]; then
        if [ "${P_ALL}" = false ]; then
          result=false
        fi
      fi
    fi
  fi

  echo "${result}"
}

function error_if_project_not_could_by_identify {
  local result=$(is_project_could_by_identify)

  if [ "${result}" = false ]; then
    echo "Missing --name, --id, --group or --all" >&2
    display_usage
  fi
}

function get_project_full_list {
  error_if_project_not_could_by_identify || exit 1

  # Note: if "${PROJECT_ID}" is define request time is smallest. 
  if [ "${P_RAW}" = "true" ] ; then
    list_projects_raw "${PROJECT_ID}" 'statistics=true' || exit 1
  else
    list_projects "${PROJECT_ID}" '' || exit 1
  fi
}

function show_projects_config_handle_params {
  local answer=$(get_project_full_list) || exit 1

  local jq_filter=

  if [ "${P_RAW}" = "true" ] ; then
    if [ ! -z "${GROUP_NAME}" ]; then
      jq_filter="[.[] | select(.namespace.name==\"${GROUP_NAME}\")]"
    elif [ ! -z "${PROJECT_NAME}" ]; then
      jq_filter="[.[] | select(.name==\"${PROJECT_NAME}\")]"
    else
      jq_filter="."
    fi
  else
    if [ ! -z "${GROUP_NAME}" ]; then
      jq_filter="[.[] | select(.group_name==\"${GROUP_NAME}\")]"
    elif [ ! -z "${PROJECT_NAME}" ]; then
      jq_filter="[.[] | select(.project_name==\"${PROJECT_NAME}\")]"
    else
      jq_filter="."
    fi
  fi

  local result=$(echo "${answer}" |jq "${jq_filter}" ) || exit 1
  local size=$(echo "${result}" |jq '. | length' ) || exit 1

  if [ $size -eq 0 ] ; then
    echo "No project available." >&2
    exit 1
  fi

  echo "jq_filter=${jq_filter}" >&2
  echo "size=${size}" >&2
  echo "${result}"
}

function list_projects_names_handle_params {
  local answer=$(show_projects_config_handle_params)

  local jq_filter=

  if [ "${P_RAW}" = "true" ] ; then
    jq_filter='.[] | .name'
  else
    jq_filter='.[] | .project_name'
  fi

  echo "${answer}" | jq -r "${jq_filter}"
}

function list_projects_ids_handle_params {
  local answer=$(show_projects_config_handle_params)

  local jq_filter=

  if [ "${P_RAW}" = "true" ] ; then
    jq_filter='.[] | .id'
  else
    jq_filter='.[] | .project_id'
  fi

  echo "${answer}" | jq -r "${jq_filter}"
}

function delete_project_handle_params {
  local project_id=

  if [ -z "${PROJECT_ID}" ]; then
    ensure_not_empty "GROUP_NAME"
    ensure_not_empty "PROJECT_NAME"
    project_id=$(get_project_id "${GROUP_NAME}" "${PROJECT_NAME}") || exit 1
  else
    project_id=${PROJECT_ID}
  fi

  delete_project "${project_id}"
  exit $?
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
if [ $# -eq 0 ]; then
  display_usage
fi

# Parameters
PROJECT_ID=
PROJECT_NAME=
GROUP_NAME=
P_RAW=true
P_ALL=false
ACTION=

while [[ $# > 0 ]]
do
param="$1"
shift
case "${param}" in
    -a|--all)
        P_ALL=true
        ;;
    --compact)
        P_RAW=false
        ;;
    --config)
        ensure_empty ACTION
        ACTION=showConfigAction
        ;;
    --delete)
        ensure_empty ACTION
        ACTION=deleteAction
        ;;
    -g|--group)
        GROUP_NAME="$1"
        shift
        ;;
    -i|--id)
        PROJECT_ID="$1"
        shift
        ;;
    --list-name)
        ensure_empty ACTION
        ACTION=listNamesAction
        ;;
    --list-id)
        ensure_empty ACTION
        ACTION=listIdsAction
        ;;
    -n|--name)
        PROJECT_NAME="$1"
        shift
        ;;
    *)
        # unknown option
        echo "Undefine parameter ${param}" >&2
        display_usage
        ;;
esac
done

case "${ACTION}" in
    deleteAction) 
        delete_project_handle_params
        ;;
    listNamesAction) 
        list_projects_names_handle_params
        ;;
    listIdsAction) 
        list_projects_ids_handle_params
        ;;
    showConfigAction)
        show_projects_config_handle_params
        ;;
    *)
        # unknown option
        echo "Missing --config, --list-name, --list-id or --delete * ${ACTION}" >&2
        display_usage
        ;;
esac


# List all id
# ./glProjects.sh --all | jq '. [] | .id'

# List name and id
# ./glProjects.sh --all | jq '[ . [] | { project_name: .name, project_id: .id } ]'

# Number of projects visible for current user
# ./glProjects.sh --all | jq '. | length'

#
# ./glProjects.sh --all | jq "[.[] | select(.group_name==\"${GROUP_NAME}\")]"
# ./glProjects.sh --all --raw | jq "[.[] | select(.namespace.path==\"${GROUP_NAME}\")]"


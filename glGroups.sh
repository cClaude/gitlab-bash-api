#!/bin/bash

function display_usage {
  echo "Usage: $0" >&2
  echo "  Get groups configuration" >&2
  echo "    $0 --config --name GROUP_NAME" >&2
  echo "    $0 --config --id GROUP_ID" >&2
  echo "    $0 --config --all" >&2
  echo "  List groups names" >&2
  echo "    $0 --list-name --name GROUP_NAME" >&2
  echo "    $0 --list-name --id GROUP_ID" >&2
  echo "    $0 --list-name --all" >&2
  echo "  List groups ids" >&2
  echo "    $0 --list-id --name GROUP_NAME" >&2
  echo "    $0 --list-id --id GROUP_ID" >&2
  echo "    $0 --list-id --all" >&2
  echo "  Delete a group" >&2
  echo "    $0 --delete --group GROUP_NAME" >&2
  echo "    $0 --delete --id GROUP_ID" >&2
  exit 100
}

function delete_group {
  local group_id=$1

  echo "delete_group NOT IMPLEMTED" >&2
  exit 1
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

  local result=$(list_groups_raw "${group_name_or_id_or_empty}" '')

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

  local result=$(list_groups_raw "${group_name_or_id_or_empty}" '')

  if [ -z "${group_name_or_id_or_empty}" ]; then
    echo "${result}" | jq '. [] | .id'
  else
    echo "${result}" | jq '. | .id'
  fi
}

function show_groups_config {
  local group_name_or_id_or_empty=$1

  local result=$(list_groups_raw "${group_name_or_id_or_empty}" '')

  if [ ! -z "${group_name_or_id_or_empty}" ]; then
    echo "${result}"
    exit 0
  fi

  # Handle --all
  local groups_ids=$(echo "${result}" | jq '. [] | .id')

  local first=true

  echo -n '['
  for id in ${groups_ids}; do
    if [ "${first}" = true ]; then
      first=false
    else
      echo -n ','
    fi
    list_groups_raw "${id}" ''
  done
  echo -n ']'
}

function show_groups_config_handle_params {
  local group_name_or_id_or_empty="${GROUP_ID}"

  if [ -z "${group_name_or_id_or_empty}" ]; then
    group_name_or_id_or_empty="${GROUP_NAME}"
  fi

  local result=$(show_groups_config "${group_name_or_id_or_empty}")

  echo "${result}" | jq .
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
GROUP_ID=
GROUP_NAME=
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
    --config)
        ensure_empty ACTION
        ACTION=showConfigAction
        ;;
    --delete)
        ensure_empty ACTION
        ACTION=deleteAction
        ;;
    -i|--id)
        GROUP_ID="$1"
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
        GROUP_NAME="$1"
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
        delete_group_handle_params
        ;;
    listNamesAction)
        list_groups_names_handle_params
        ;;
    listIdsAction)
        list_groups_ids_handle_params
        ;;
    showConfigAction)
        show_groups_config_handle_params
        ;;
    *)
        # unknown option
        echo "Missing --config, --list-name, --list-id or --delete * ${ACTION}" >&2
        display_usage
        ;;
esac

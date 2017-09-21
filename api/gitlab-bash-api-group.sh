#!/bin/bash

# API: list_groups

function list_groups {
  local group_id=$1
  local params=$2

  local answer=$(gitlab_get "groups/${group_id}" "${params}") || exit 101
  echo "${answer}"
}

# API: show_group_config

function show_group_config {
  local group_name_or_id_or_empty=$1

  local result=$(list_groups "${group_name_or_id_or_empty}" '')

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
    list_groups "${id}" ''
  done
  echo -n ']'
}

# API: edit_group

function edit_group {
  local group_id=$1
  local group_name=$2
  local group_path=$3
  local group_description=$4
  local group_visibility=$5
  local group_lfs_enabled=$6
  local group_request_access_enabled=$7

  # visibility_level
  # - private : ??
  # - internal: ??
  # - public  : 20

  #echo "edit group '${group_id}' '${group_name}' '${group_path}' '${group_description}' '${group_visibility}' '${group_lfs_enabled}' '${group_request_access_enabled}'" >&2

  local params="name=$(urlencode "${group_name}")&path=${group_path}"
  params+="&description=$(urlencode "${group_description}")"
  params+="&visibility=${group_visibility}"
  params+="&lfs_enabled=${group_lfs_enabled}"
  params+="&request_access_enabled=${group_request_access_enabled}"

  # echo "POST params: ${params}" >&2
  gitlab_put "groups/${group_id}" "${params}"
}

# API: delete_group

function delete_group {
  local group_id=$1

  echo "delete_group NOT IMPLEMTED" >&2
  exit 1
}


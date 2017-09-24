#!/bin/bash

# Monstly based on https://docs.gitlab.com/ce/api/groups.html

# API: list_groups

function list_groups {
  local group_id=$1
  local params=$2

  gitlab_get "groups/${group_id}" "${params}"
}

# API: search_group_

function search_group_ {
  local group_id=$1

  gitlab_get "groups/search=${search_string}" ''
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

# API: create_group

function create_group {
  local params=
  local first=true

  # optional parameters
  while [[ $# > 0 ]]; do
    if [ ! $# \> 1 ]; then
      echo "*** create_group error: odd number of remind parameters. $#" >&2
      exit 1
    fi

    local param_name="$1"
    shift
    local param_value="$1"
    shift

    if [ "${first}" = true ]; then
      first=false
    else
      params+='&'
    fi

    params+="${param_name}=$(urlencode "${param_value}")"
  done

  # DEBUG echo "# create_group POST params: ${params}" >&2
  gitlab_post 'groups' "${params}"
}

# API: create_group_params

function create_group_params {
  echo '
path
name
description
lfs_enabled
membership_lock
request_access_enabled
share_with_group_lock
visibility
'
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

  echo "# delete group: group_id=[${group_id}]" >&2

  gitlab_delete "groups/${group_id}"
}


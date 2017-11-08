#!/bin/bash

# Monstly based on https://docs.gitlab.com/ce/api/groups.html

# API: list_groups

function list_groups {
  local group_id=$1
  local params=$2

  gitlab_get "groups/$(urlencode "${group_id}")" "${params}"
}

# API: search_group_ (ALPHA)

function search_group_ {
  local search_string=$1

  gitlab_get "groups/search=$(urlencode "${search_string}")" ''
}

# API: get_group_id_from_group_path

function get_group_id_from_group_path {
  local group_path="$1"
  local answer
  local group_id

  answer=$(gitlab_get "groups/$(urlencode "${group_path}")") || return 1

  group_id=$(echo "${answer}" | jq .id)

  if [ -z "${group_id}" ] ; then
    echo "*** GROUP_PATH '${group_path}' doest not exist - '${answer}'" >&2
    exit 200
  fi

  if [ "${group_id}" = "null" ] ; then
    echo "*** GROUP_PATH '${group_path}' doest not exist - '${answer}'" >&2
    exit 201
  fi

  echo "${group_id}"
}

# API: show_group_config

function show_group_config {
  local group_path_or_id_or_empty=$1
  local result

  result=$(list_groups "${group_path_or_id_or_empty}" '')

  if [ ! -z "${group_path_or_id_or_empty}" ]; then
    echo "${result}"
    exit 0
  fi

  # Handle --all
  local groups_ids

  groups_ids=$(echo "${result}" | jq '. [] | .id')

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
  while [[ $# -gt 0 ]]; do
    if [ ! $# -gt 1 ]; then
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
  local group_description_define=$4
  local group_description=$5
  local group_visibility=$6
  local group_lfs_enabled=$7
  local group_request_access_enabled=$8

  if [ -z "${group_id}" ]; then
    echo "*** error: edit_group missing group_id" >&2
    exit 1
  fi
  if [ -z "${group_name}" ]; then
    echo "*** error: edit_group missing group_name" >&2
    exit 1
  fi
  if [ -z "${group_path}" ]; then
    echo "*** error: edit_group missing group_path" >&2
    exit 1
  fi
  ensure_boolean "${group_description_define}" 'group_description_define'

  local params

  params="name=$(urlencode "${group_name}")&path=${group_path}"

  if [ "${group_description_define}" = true ]; then
    params+="&description=$(urlencode "${group_description}")"

    if [ -z "${group_description}" ]; then
      echo "*** warning: edit_group group_description is empty" >&2
    fi
  fi
  if [ ! -z "${group_visibility}" ]; then
    params+="&visibility=${group_visibility}"
  fi
  if [ ! -z "${group_lfs_enabled}" ]; then
    params+="&lfs_enabled=${group_lfs_enabled}"
  fi
  if [ ! -z "${group_request_access_enabled}" ]; then
    params+="&request_access_enabled=${group_request_access_enabled}"
  fi

  # DEBUG echo "POST params edit_group: ${params}" >&2
  gitlab_put "groups/${group_id}" "${params}"
}

# API: delete_group

function delete_group {
  local group_id=$1

  echo "# delete group: group_id='${group_id}'" >&2

  gitlab_delete "groups/${group_id}"
}


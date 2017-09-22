#!/bin/bash

function isArray {
  local begin=$(echo "$1" | cut -b1 )

  if [ "${begin}" = '[' ] ; then
    echo "true"
  else
    echo "false"
  fi
}

# API: list_projects_raw

function list_projects_raw {
  local project_id=$1
  local params=$2

  local answer=$(gitlab_get "projects/${project_id}" "${params}") || exit 102
  local error_message=$(getErrorMessage "${answer}") 

  if [ ! -z "${error_message}" ]; then
    echo "${answer}" # This is an error (not format)
    exit 0
  fi

  if [ ! -z "${project_id}" ]; then
    #DEBUG echo "isArray:$(isArray "${answer}") should be false ${project_id}" >&2
    echo "[${answer}]" # Always return an array (even when not found)
  else
    #DEBUG echo "isArray:$(isArray "${answer}") should be true" >&2
    echo "${answer}"
  fi
}

# API: list_projects_compact

function list_projects_compact {
  local project_id=$1
  local params=$2
  local json=

  local answer=$(list_projects_raw "${project_id}" "${params}") || exit 103

  local short_result=$(echo "${answer}" | jq '[.[] | {
project_id: .id,
project_name: .name,
project_path: .path,
group_name: .namespace.name,
path_with_namespace: .path_with_namespace,
ssh_url_to_repo: .ssh_url_to_repo,
http_url_to_repo: .http_url_to_repo,
container_registry_enabled: .container_registry_enabled,
issues_enabled: .issues_enabled,
merge_requests_enabled: .merge_requests_enabled,
wiki_enabled: .wiki_enabled,
builds_enabled: .builds_enabled,
snippets_enabled: .snippets_enabled,
shared_runners_enabled: .shared_runners_enabled,
lfs_enabled: .lfs_enabled,
request_access_enabled: .request_access_enabled
}]') || ext 104

  echo "${short_result}"
}

# API: show_project_config

function show_project_config {
  local param_raw_display=$1
  local param_project_id=$2

  if [ ! $# -eq 2 ]; then
    echo "* show_project_config: Expecting 2 parameters found $# : '$@'" >&2
    exit 1
  fi

  ensure_boolean "${param_raw_display}" 'param_raw_display' || exit 1

  #DEBUG echo "### show_project_config '$1' - '$2'" >&2

  # Note: if "${param_project_id}" is define request time is smallest.
  if [ "${param_raw_display}" = "true" ] ; then
    list_projects_raw "${param_project_id}" 'statistics=true' || exit 1
  else
    list_projects_compact "${param_project_id}" '' || exit 1
  fi
}

# API: edit_project

function edit_project {

  echo "edit_project NOT IMPLEMTED" >&2
  exit 1
}

# API: delete_project

function delete_project {
  local project_id=$1
  local answer=

  echo "# delete project: project_id=[${project_id}]" >&2

  answer=$(delete_projects_by_id "${project_id}") || exit 1

  echo "${answer}"
}

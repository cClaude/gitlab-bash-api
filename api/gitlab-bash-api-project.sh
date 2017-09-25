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
group_path: .namespace.path,
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
}]')

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

# API: create_project

function create_project {
  local params=
  local first=true

  # optional parameters
  while [[ $# > 0 ]]; do
    if [ ! $# \> 1 ]; then
      echo "*** create_project error: odd number of remind parameters. $#" >&2
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

  case "${param_name}" in
    printing_merge_request_link_enabled|container_registry_enabled)
        ensure_boolean "${param_value}" "${param_name}"

        params+="${param_name}=${param_value}"
        ;;
    *)
        params+="${param_name}=$(urlencode "${param_value}")"
        ;;
  esac

  done

  # DEBUG echo "POST params: ${params}" >&2
  gitlab_post 'projects' "${params}"
}

# API: create_project_params

function create_project_params {
  echo '
path
name
namespace_id
description
container_registry_enabled
issues_enabled
jobs_enabled
lfs_enabled
merge_requests_enabled
only_allow_merge_if_all_discussions_are_resolved
only_allow_merge_if_pipeline_succeed
printing_merge_request_link_enabled
public_jobs
request_access_enabled
snippets_enabled
visibility
wiki_enabled
'
}

# API: edit_project

function edit_project {
  # required
  local p_id=$1   # The ID or URL-encoded path of the project
  local p_name=$2 # The name of the project

  shift
  shift

  local params="name=$(urlencode "${p_name}")"

  # optional parameters
  while [[ $# > 0 ]]; do
    if [ ! $# \> 1 ]; then
      echo "*** edit_project error: odd number of remind parameters. $#" >&2
      exit 1
    fi

    local param_name="$1"
    shift
    local param_value="$1"
    shift

    params+="&${param_name}=$(urlencode "${param_value}")"
  done

  # DEBUG echo "POST params: ${params}" >&2
  gitlab_put "projects/${p_id}" "${params}"
}

# API: edit_project_all_values

function edit_project_all_values {
  local p_id=$1     # The ID or URL-encoded path of the project
  local p_name=$2   # The name of the project
  local p_path=$3   # Custom repository name for the project.
  local p_default_branch=$4         # master by default
  local p_description=$5            # Short project description
  local p_issues_enabled=$6         # Enable issues for this project
  local p_merge_requests_enabled=$7 # Enable merge requests for this project
  local p_jobs_enabled=$8           # Enable jobs for this project
  local p_wiki_enabled=$9           # Enable wiki for this project
  local p_snippets_enabled=$10      # Enable snippets for this project
  local p_resolve_outdated_diff_discussions=$11 # Automatically resolve merge request diffs discussions on lines changed with a push
  local p_container_registry_enabled=$12        # Enable container registry for this project
  local p_shared_runners_enabled=$13            # Enable shared runners for this project
  local p_visibility=$14        # See project visibility level
  local p_import_url=$15        # URL to import repository from
  local p_public_jobs=$16       # If true, jobs can be viewed by non-project-members
  local p_only_allow_merge_if_pipeline_succeeds=$17             # Set whether merge requests can only be merged with successful jobs
  local p_only_allow_merge_if_all_discussions_are_resolved=$18  # Set whether merge requests can only be merged when all the discussions are resolved
  local p_lfs_enabled=$19               # Enable LFS
  local p_request_access_enabled=$20    # Allow users to request member access
  local p_tag_list=$21          # The list of tags for a project; put array of tags, that should be finally assigned to a project
  local p_avatar=$22            # Image file for avatar of the project
  local p_ci_config_path=$23    # The path to CI config file

  edit_project "${p_id}" "${p_name}" \
    'path' "${p_path}" \
    'default_branch' "${p_default_branch}" \
    'description' "${p_description}" \
    'issues_enabled' "${p_issues_enabled}" \
    'merge_requests_enabled' "${p_merge_requests_enabled}" \
    'jobs_enabled' "${p_jobs_enabled}" \
    'wiki_enabled' "${p_wiki_enabled}" \
    'snippets_enabled' "${p_snippets_enabled}" \
    'resolve_outdated_diff_discussions' "${p_resolve_outdated_diff_discussions}" \
    'container_registry_enabled' "${p_container_registry_enabled}" \
    'shared_runners_enabled' "${p_shared_runners_enabled}" \
    'visibility' "${p_visibility}" \
    'import_url' "${p_import_url}" \
    'public_jobs' "${p_public_jobs}" \
    'only_allow_merge_if_pipeline_succeeds' "${p_only_allow_merge_if_pipeline_succeeds}" \
    'only_allow_merge_if_all_discussions_are_resolved' "${p_only_allow_merge_if_all_discussions_are_resolved}" \
    'lfs_enabled' "${p_lfs_enabled}" \
    'request_access_enabled' "${p_request_access_enabled}" \
    'tag_list' "${p_tag_list}" \
    'avatar' "${p_avatar}" \
    'ci_config_path' "${p_ci_config_path}"
}

# API: delete_project

function delete_project {
  local project_id=$1

  echo "# delete project: project_id=[${project_id}]" >&2

  gitlab_delete "projects/${project_id}"
}

# API: get_all_projects_path_with_namespace

function get_all_projects_path_with_namespace {
  local project_paths=$(list_projects_compact '' '' | jq -r '.[] | .path_with_namespace' ) || exit 401

  echo "${project_paths}" | sort
}


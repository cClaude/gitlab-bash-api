#!/bin/bash

# API: list_branches

function list_branches {
  local project_id=$1
  local branch_name=$2

  local answer
  local error_message

  answer=$(gitlab_get "/projects/${project_id}/repository/branches/${branch_name}")
  error_message=$(getErrorMessage "${answer}")

  if [ ! -z "${error_message}" ]; then
    echo "${answer}" # This is an error (not format)
    exit 0
  fi

  echo "${answer}"
}

# API: show_project_config

function show_project_config {
  local param_raw_display=$1
  local param_project_id=$2

  if [ ! $# -eq 2 ]; then
    echo "* show_project_config: Expecting 2 parameters found $# : '$*'" >&2
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
  while [[ $# -gt 0 ]]; do
    if [ ! $# -gt 1 ]; then
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

  # DEBUG echo "POST params create_project: ${params}" >&2
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
only_allow_merge_if_pipeline_succeeds
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
  local project_id=
  local first=true

  # optional parameters
  while [[ $# -gt 0 ]]; do
    if [ ! $# -gt 1 ]; then
      echo "*** edit_project error: odd number of remind parameters. $# ($1) : Current parameters ${params}" >&2
      exit 1
    fi

    local param_name="$1"
    shift
    local param_value="$1"
    shift

    if [ "${param_name}" = 'id' ]; then
      # handle id
      project_id=${param_value}
    else
      if [ "${first}" = true ]; then
        first=false
      else
        params+='&'
      fi

      params+="${param_name}=$(urlencode "${param_value}")"
    fi

  done

  if [ -z "${project_id}" ]; then
    echo '* edit_project project id is missing.' >&2
    exit 1
  fi

  # DEBUG echo "POST params edit_project: ${params}" >&2
  gitlab_put "projects/${project_id}" "${params}"
}

# API: edit_project_parameters

function edit_project_parameters {
  echo '
id
name
path
default_branch
description
issues_enabled
merge_requests_enabled
jobs_enabled
wiki_enabled
snippets_enabled
resolve_outdated_diff_discussions
container_registry_enabled
shared_runners_enabled
visibility
import_url
public_jobs
only_allow_merge_if_pipeline_succeeds
only_allow_merge_if_all_discussions_are_resolved
lfs_enabled
request_access_enabled
tag_list
avatar
ci_config_path
'
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
  local p_snippets_enabled=${10}    # Enable snippets for this project
  local p_resolve_outdated_diff_discussions=${11} # Automatically resolve merge request diffs discussions on lines changed with a push
  local p_container_registry_enabled=${12}        # Enable container registry for this project
  local p_shared_runners_enabled=${13}            # Enable shared runners for this project
  local p_visibility=${14}        # See project visibility level
  local p_import_url=${15}        # URL to import repository from
  local p_public_jobs=${16}       # If true, jobs can be viewed by non-project-members
  local p_only_allow_merge_if_pipeline_succeeds=${17}             # Set whether merge requests can only be merged with successful jobs
  local p_only_allow_merge_if_all_discussions_are_resolved=${18}  # Set whether merge requests can only be merged when all the discussions are resolved
  local p_lfs_enabled=${19}               # Enable LFS
  local p_request_access_enabled=${20}    # Allow users to request member access
  local p_tag_list=${21}          # The list of tags for a project; put array of tags, that should be finally assigned to a project
  local p_avatar=${22}            # Image file for avatar of the project
  local p_ci_config_path=${23}    # The path to CI config file

  edit_project \
    'id' "${p_id}" \
    'name' "${p_name}" \
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
  local project_paths

  project_paths=$(list_projects_compact '' '' | jq -r '.[] | .path_with_namespace' ) || exit 401

  echo "${project_paths}" | sort
}


#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html#create-project
#
# Parameters:
#   name                                string          yes if path is not provided     The name of the new project. Equals path if not provided.
#   path                                string          yes if name is not provided     Repository name for new project. Generated based on name if not provided (generated lowercased with dashes).
#   namespace_id                        integer         no      Namespace for the new project (defaults to the current user's namespace)
#   description                         string          no      Short project description
#
#   avatar                              mixed           no      Image file for avatar of the project
#   ci_config_path                      string          no      The path to CI config file
#   container_registry_enabled          boolean         no      Enable container registry for this project
#   import_url                          string          no      URL to import repository from
#   issues_enabled                      boolean         no      Enable issues for this project
#   jobs_enabled                        boolean         no      Enable jobs for this project
#   lfs_enabled                         boolean         no      Enable LFS
#   merge_requests_enabled              boolean         no      Enable merge requests for this project
#   only_allow_merge_if_all_discussions_are_resolved    boolean         no      Set whether merge requests can only be merged when all the discussions are resolved
#   only_allow_merge_if_pipeline_succeeds               boolean         no      Set whether merge requests can only be merged with successful jobs
#   printing_merge_request_link_enabled boolean         no      Show link to create/view merge request when pushing from the command line
#   public_jobs                         boolean         no      If true, jobs can be viewed by non-project-members
#   request_access_enabled              boolean         no      Allow users to request member access
#   shared_runners_enabled              boolean         no      Enable shared runners for this project
#   snippets_enabled                    boolean         no      Enable snippets for this project
#   tag_list                            array           no      The list of tags for a project; put array of tags, that should be finally assigned to a project
#   visibility                          string          no      See project visibility level
#   wiki_enabled                        boolean         no      Enable wiki for this project
#

function create_project_from_params {
  local group_id=$1
  local project_path=$2
  local project_name=$3
  local project_description=$4

  echo "# create project: GROUP_ID=${group_id} - PROJECT_PATH=[${project_path}] / PROJECT_NAME=[${project_name}] - PROJECT_DESCRIPTION=[${project_description}]"

  # Build paramters
  local answer=$(create_project path "${project_path}" \
      name "${project_name}" \
      namespace_id "${group_id}" \
      description "${project_description}" \
      container_registry_enabled "${GITLAB_DEFAULT_PROJECT_CONTAINER_REGISTRY_ENABLED}" \
      issues_enabled "${GITLAB_DEFAULT_PROJECT_ISSUES_ENABLED}" \
      jobs_enabled "${GITLAB_DEFAULT_PROJECT_JOBS_ENABLED}" \
      lfs_enabled "${GITLAB_DEFAULT_PROJECT_LFS_ENABLED}" \
      merge_requests_enabled "${GITLAB_DEFAULT_PROJECT_MERGE_REQUESTS_ENABLED}" \
      only_allow_merge_if_all_discussions_are_resolved "${GITLAB_DEFAULT_PROJECT_ONLY_ALLOW_MERGE_IF_ALL_DISCUSSIONS_ARE_RESOLVED}" \
      only_allow_merge_if_pipeline_succeed "${GITLAB_DEFAULT_PROJECT_ONLY_ALLOW_MERGE_IF_PIPELINE_SUCCEED}" \
      printing_merge_request_link_enabled "${GITLAB_DEFAULT_PROJECT_PRINTING_MERGE_REQUEST_LINK_ENABLED}" \
      public_jobs "${GITLAB_DEFAULT_PROJECT_PUBLIC_JOBS}" \
      request_access_enabled "${GITLAB_DEFAULT_PROJECT_REQUEST_ACCESS_ENABLED}" \
      snippets_enabled "${GITLAB_DEFAULT_PROJECT_SNIPPETS_ENABLED}" \
      visibility "${GITLAB_DEFAULT_PROJECT_VISIBILITY}" \
      wiki_enabled "${GITLAB_DEFAULT_PROJECT_WIKI_ENABLED}")

  local project_id=$(echo "${answer}" | jq .id)

  if [ "${project_id}" = "null" ] ; then
    echo "*** GROUP_ID=${group_id}/PROJECT_NAME=[${project_name}] not created - already exist ?" >&2
    echo "${answer}" >&2
    exit 100
  fi

  echo "# GROUP_ID=${GROUP_ID} PROJECT_ID=${project_id}"
}

function main {
  if [[ $# -lt 2 ]] ; then
    echo "Usage: $0 GROUP_NAME PROJECT_PATH ['PROJECT_NAME' ['PROJECT_DESCRIPTION']]" >&2
    exit 1
  fi

  # Parameters
  local group_name=$1
  local project_path=$2
  local project_name=$3
  local project_description=

  if [ ! -z "$4" ] ; then
    project_description="$4"
  else
    project_description="${GITLAB_DEFAULT_PROJECT_DESCRIPTION}"
  fi

  local group_id=$(get_groupid_from_group_name "${group_name}") || exit 1

  if [ -z "${project_name}" ] ; then
    project_name="${project_path}"
  fi

  create_project_from_params "${group_id}" "${project_path}" "${project_name}" "${project_description}"
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
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-project.sh"

# Script start here
main "$@"


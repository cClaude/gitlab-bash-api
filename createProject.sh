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

# Configuration
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(realpath "$0"))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"

# Script start here
if [[ $# -lt 2 ]] ; then
  echo "Usage: $0 GROUP_NAME PROJECT_PATH ['PROJECT_NAME' ['PROJECT_DESCRIPTION']]" >&2
  exit 1
fi

# Parameters
GROUP_NAME=$1
PROJECT_PATH=$2
PROJECT_NAME=$3

if [ ! -z "$4" ] ; then
  PROJECT_DESCRIPTION="$4"
else
  PROJECT_DESCRIPTION="${GITLAB_PROJECT_DESCRIPTION}"
fi

GROUP_ID=$(get_groupid_from_group_name "${GROUP_NAME}") || exit 1

if [ -z "${PROJECT_NAME}" ] ; then
  PROJECT_NAME="${PROJECT_PATH}"
fi

echo "# create project: GROUP_ID=${GROUP_ID} / GROUP_NAME=[${GROUP_NAME}] - PROJECT_PATH=[${PROJECT_PATH}] / PROJECT_NAME=[${PROJECT_NAME}] - PROJECT_DESCRIPTION=[${PROJECT_DESCRIPTION}]"

# Build paramters
PARAMS="path=${PROJECT_PATH}"

ENCODED=$(urlencode "${PROJECT_NAME}")
PARAMS+="&name=${ENCODED}"

PARAMS+="&namespace_id=${GROUP_ID}"

ENCODED=$(urlencode "${PROJECT_DESCRIPTION}")
PARAMS+="&description=${ENCODED}"

PARAMS+="&container_registry_enabled=${GITLAB_PROJECT_CONTAINER_REGISTRY_ENABLED}"
PARAMS+="&issues_enabled=${GITLAB_PROJECT_ISSUES_ENABLED}"
PARAMS+="&jobs_enabled=${GITLAB_PROJECT_JOBS_ENABLED}"
PARAMS+="&lfs_enabled=${GITLAB_PROJECT_LFS_ENABLED}"
PARAMS+="&merge_requests_enabled=${GITLAB_PROJECT_MERGE_REQUESTS_ENABLED}"
PARAMS+="&only_allow_merge_if_all_discussions_are_resolved=${GITLAB_PROJECT_ONLY_ALLOW_MERGE_IF_ALL_DISCUSSIONS_ARE_RESOLVED}"
PARAMS+="&only_allow_merge_if_pipeline_succeed=${GITLAB_PROJECT_ONLY_ALLOW_MERGE_IF_PIPELINE_SUCCEED}"
PARAMS+="&printing_merge_request_link_enabled=${GITLAB_PROJECT_PRINTING_MERGE_REQUEST_LINK_ENABLED}"
PARAMS+="&public_jobs=${GITLAB_PROJECT_PUBLIC_JOBS}"
PARAMS+="&request_access_enabled=${GITLAB_PROJECT_REQUEST_ACCESS_ENABLED}"
PARAMS+="&snippets_enabled=${GITLAB_PROJECT_SNIPPETS_ENABLED}"
PARAMS+="&visibility=${GITLAB_PROJECT_VISIBILITY}"
PARAMS+="&wiki_enabled=${GITLAB_PROJECT_WIKI_ENABLED}"

#echo "$PARAMS"

answer=$(gitlab_post 'v3' "projects" "${PARAMS}") || exit 1
PROJECT_ID=$(echo "${answer}" | jq .id)

if [ "${PROJECT_ID}" = "null" ] ; then
  echo "*** GROUP_ID=${GROUP_ID}/PROJECT_NAME=[${PROJECT_NAME}] not created - already exist ?" >&2
  echo "${answer}" >&2
  exit 100
fi

echo "# GROUP_ID=${GROUP_ID} PROJECT_ID=${PROJECT_ID}"

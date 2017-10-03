#!/bin/bash

source "$(dirname $(realpath "$0"))/generated-config-bootstrap/init.sh"

declare -r GLGROUPS="${GITLAB_BASH_API_PATH}/glGroups.sh"
declare -r GLPROJECTS="${GITLAB_BASH_API_PATH}/glProjects.sh"

declare -r TEST_GROUP_PATH=group_for_glProjects_tests

ERROR_COUNT=0

function test_value {
  local result=$1
  local json_field=$2
  local expected_value=$3

  local value=$(echo "${result}" | jq -r ". | ${json_field}")
  if [ ! "${expected_value}" = "${value}" ]; then
    echo "*** Error bad value for ${json_field}: found '${value}' expected '${expected_value}'." >&2
    ERROR_COUNT=$(echo $((${ERROR_COUNT}+1)))
  fi
}

function glProjects_edit_all {
  local project_id=${1}
  local project_name=${2}
  local project_path=${3}
  local project_description=${4}
  local container_registry_enabled=${5}
  local issues_enabled=${6}
  local jobs_enabled=${7}
  local lfs_enabled=${8}
  local merge_requests_enabled=${9}
  local only_allow_merge_if_all_discussions_are_resolved=${10}
  local only_allow_merge_if_pipeline_succeed=${11}
  local public_jobs=${12}
  local request_access_enabled=${13}
  local snippets_enabled=${14}
  local visibility=${15} # VISIBILITY=private|internal|public
  local wiki_enabled=${16}

  local result=$("${GLPROJECTS}" --edit \
    --id ${project_id} \
    --project-name "${project_name}" \
    --path "${project_path}" \
    --project-description "${project_description}" \
    --container-registry-enabled ${container_registry_enabled} \
    --issues-enabled ${issues_enabled} \
    --jobs-enabled ${jobs_enabled} \
    --lfs-enabled ${lfs_enabled} \
    --merge-requests-enabled ${merge_requests_enabled} \
    --only-allow-merge-if-all-discussions-are-resolved ${only_allow_merge_if_all_discussions_are_resolved} \
    --only-allow-merge-if-pipeline-succeed ${only_allow_merge_if_pipeline_succeed} \
    --public-jobs ${public_jobs} \
    --request-access-enabled  ${request_access_enabled} \
    --snippets-enabled ${snippets_enabled} \
    --visibility ${visibility} \
    --wiki-enabled ${wiki_enabled})

  echo "${result}"

  test_value "${result}" '.id'                  "${project_id}"
  test_value "${result}" '.name'                "${project_name}"
  test_value "${result}" '.path'                "${project_path}"
  test_value "${result}" '.description'         "${project_description}"
  test_value "${result}" '.container_registry_enabled'  "${container_registry_enabled}"
  test_value "${result}" '.issues_enabled'              "${issues_enabled}"
  test_value "${result}" '.builds_enabled'              "${jobs_enabled}" # ????????
  test_value "${result}" '.lfs_enabled'                 "${lfs_enabled}"
  test_value "${result}" '.merge_requests_enabled'      "${merge_requests_enabled}"
  test_value "${result}" '.only_allow_merge_if_all_discussions_are_resolved' "${only_allow_merge_if_all_discussions_are_resolved}"
  test_value "${result}" '.only_allow_merge_if_build_succeeds'               "${only_allow_merge_if_pipeline_succeed}"
  test_value "${result}" '.public_builds'           "${public_jobs}" # ????????
  test_value "${result}" '.request_access_enabled'  "${request_access_enabled}"
  test_value "${result}" '.snippets_enabled'        "${snippets_enabled}"
  test_value "${result}" '.visibility_level'        "${visibility}"
  test_value "${result}" '.wiki_enabled'            "${wiki_enabled}"
}

echo '#
# Create group
#'
"${GLGROUPS}" --create --path ${TEST_GROUP_PATH} --name "test group for projects"  --visibility public

echo '#
# Display all groups names
#'
echo 'Group list - begin'
"${GLGROUPS}" --list-path --all
echo 'Group list - end'
group_id=$("${GLGROUPS}" --list-id --path ${TEST_GROUP_PATH})

echo "Group ID=${group_id}"

if [ -z "${group_id}" ]; then
  echo '*** ERROR: Can not create initial/find group.'
  exit 1
fi

echo '#
# Create project
#'
"${GLPROJECTS}" --create \
      --group-id "${group_id}" \
      --path 'a_project_path' \
      --project-name 'a project name' \
      --project-description 'a project description' \
      --container-registry-enabled 'true' \
      --issues-enabled 'true' \
      --jobs-enabled 'true' \
      --lfs-enabled 'true' \
      --merge-requests-enabled 'true' \
      --only-allow-merge-if-all-discussions-are-resolved 'true' \
      --only-allow-merge-if-pipeline-succeed 'true' \
      --printing-merge-request-link-enabled 'true' \
      --public-jobs 'true' \
      --request-access-enabled 'true' \
      --snippets-enabled 'true' \
      --visibility 'private' \
      --wiki-enabled 'true'

# --visibility private public

echo '
Project list path - begin'
"${GLPROJECTS}" --list-path --all
echo 'Project list path - end
'
echo '
Project list path (compact)- begin'
"${GLPROJECTS}" --list-path --all --compact
echo 'Project list path (compact)- end
'
echo '
Project list id - begin'
"${GLPROJECTS}" --list-id --all
echo 'Project list id - end
'
echo '
Project list id (compact)- begin'
"${GLPROJECTS}" --list-id --all --compact
echo 'Project list id (compact)- end
'

project_id=$("${GLPROJECTS}" --list-id --path 'a_project_path')

echo "Project ID=${project_id}"

if [ -z "${project_id}" ]; then
  echo '*** Error project not found.'
fi

echo '#
# Display project configuration
#'
project_config_init=$("${GLPROJECTS}" --config --id "${project_id}")
echo "${project_config_init}" | jq '.'
project_id_check=$(echo "${project_config_init}" | jq '.[] | .id')
if [ ! "${project_id}" = "${project_id_check}" ]; then
  echo "*** Error project id mismatch: '${project_id}' != '${project_id_check}'" >&2
  exit 1
fi

project_name=$(echo "${project_config_init}" | jq '.[] | .name')

echo '#
# Edit project configuration
#'
glProjects_edit_all "${project_id}" "${project_name}" PROJECT_PATH "PROJECT DESCRIPTION" \
  true true true true true true true true true true \
  public \
  true

echo '#
# Delete project
#'
"${GLPROJECTS}" --delete --id "${project_id}"

echo '#
# Delete group
#'
"${GLGROUPS}" --delete --id "${group_id}"


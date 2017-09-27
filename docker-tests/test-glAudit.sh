#!/bin/bash

source "$(dirname $(realpath "$0"))/generated-config-bootstrap/init.sh"

declare RESULTS_HOME="$(dirname $(dirname $(realpath "$0")))/tests-result"
declare AUDIT_FOLDER="${RESULTS_HOME}/glAudit"


declare -r GLGROUPS="${GITLAB_BASH_API_PATH}/glGroups.sh"
declare -r GLPROJECTS="${GITLAB_BASH_API_PATH}/glProjects.sh"
declare -r GLAUDIT="${GITLAB_BASH_API_PATH}/glAudit.sh"

function getGroupId {
  local group_path=$1

  local group_id=$("${GLGROUPS}" --list-id --path "${group_path}")
  echo "Group ${group_path}=${group1_id}" >&2
  if [ "${group1_id}" = 'null' ]; then
      echo '*** ERROR: Can not create '${group_path}' group.' >&2
      exit 1
  fi
  echo "${group_id}"
}

function getProjectId {
  local project_path=$1

  local project_id=$("${GLPROJECTS}" --list-id --path "${project_path}")
  echo "Project ${project_path}=${project_id}" >&2
  if [ "${project_id}" = 'null' ]; then
      echo '*** ERROR: Can not create '${project_path}' project.' >&2
      exit 1
  fi
  echo "${project_id}"
}

echo '#
# Create groups
#'
"${GLGROUPS}" --create --path audit_group_path1
group1_id=$(getGroupId audit_group_path1)

"${GLGROUPS}" --create --path audit_group_path2
group2_id=$(getGroupId audit_group_path2)

echo '#
# Create projects
#'
"${GLPROJECTS}" --create --group-id "${group1_id}" --path 'project_1_1'
project_1_1_id=$(getProjectId project_1_1)

"${GLPROJECTS}" --create --group-id "${group2_id}" --path 'project_2_1'
project_1_1_id=$(getProjectId project_2_1)

echo "${project_1_1_id}"
echo '#
# Audit - BEGIN
#'

"${GLAUDIT}" --directory "${AUDIT_FOLDER}"

echo '#
# Audit - END
#'

echo '#
# Display groups ids
#'
GRP_LIST=$("${GLGROUPS}" --config --all | jq '[ .[] | {
id: .id,
path: .path
}]')
echo "Groups List='${GRP_LIST}'"
echo '#
# Display project ids
#'
PRG_LIST=$("${GLPROJECTS}" --config --all | jq '[ .[] | {
id: .id,
path_with_namespace: .path_with_namespace
}]')
echo "Projects List='${PRG_LIST}'"

"${GLGROUPS}" --delete --id "${group1_id}"
"${GLGROUPS}" --delete --id "${group2_id}"

echo '#
# Display remaining groups ids
#'
GRP_LIST=$("${GLGROUPS}" --list-id --all)
echo "Groups List='${GRP_LIST}'"
echo '#
# Display project groups ids
#'
PRG_LIST=$("${GLPROJECTS}" --config --all)
echo "Projects List='${PRG_LIST}'"

exit 0


"${GLPROJECTS}" --config --id "${project_1_1_id}" | jq ". | select(.[].id=${project_1_1_id}) | .[0] | {
id: .id,
archived: .archived,
avatar_url: .avatar_url,
builds_enabled: .builds_enabled,
container_registry_enabled: .container_registry_enabled,
creator_id: .creator_id,
default_branch: .default_branch,
description: .description,
http_url_to_repo: .http_url_to_repo,
issues_enabled: .issues_enabled,
lfs_enabled: .lfs_enabled,
merge_requests_enabled: .merge_requests_enabled,
name: .name,
name_with_namespace: .name_with_namespace,
only_allow_merge_if_all_discussions_are_resolved: .only_allow_merge_if_all_discussions_are_resolved,
only_allow_merge_if_build_succeeds: .only_allow_merge_if_build_succeeds,
path: .path,
path_with_namespace: .path_with_namespace,
public: .public,
public_builds: .public_builds,
request_access_enabled: .request_access_enabled,
runners_token: .runners_token,
shared_runners_enabled: .shared_runners_enabled,
snippets_enabled: .snippets_enabled,
ssh_url_to_repo: .ssh_url_to_repo,
visibility_level: .visibility_level,
web_url: .web_url,
wiki_enabled: .wiki_enabled,
}"


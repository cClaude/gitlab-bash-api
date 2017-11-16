#!/bin/bash

source "$(dirname "$(realpath "$0")")/generated-config-bootstrap/init.sh"

# RESULTS_HOME=$(dirname "$(dirname "$(realpath "$0")")")/tests-result
RESULTS_HOME=$(dirname "$(realpath "$0")")/tests-result
declare -r RESULTS_HOME=${RESULTS_HOME}

AUDIT_FOLDER=${RESULTS_HOME}/glAudit
declare -r AUDIT_FOLDER=${AUDIT_FOLDER}

REFERENCES_HOME=$(dirname "$(realpath "$0")")/references
declare -r REFERENCES_HOME=${REFERENCES_HOME}

if [ ! -d "${REFERENCES_HOME}" ]; then
  echo "*** Error REFERENCES_HOME not found: '${REFERENCES_HOME}'" >&2
  exit 100
fi

declare -r GLGROUPS=${GITLAB_BASH_API_PATH}/glGroups.sh
declare -r GLPROJECTS=${GITLAB_BASH_API_PATH}/glProjects.sh
declare -r GLAUDIT=${GITLAB_BASH_API_PATH}/glAudit.sh

function getGroupId {
  local group_path=$1
  local group_id

  group_id=$("${GLGROUPS}" --list-id --path "${group_path}")

  echo "Group ${group_path}=${group1_id}" >&2
  if [ "${group1_id}" = 'null' ]; then
      echo "*** ERROR: Can not create '${group_path}' group." >&2
      exit 1
  fi
  echo "${group_id}"
}

function getProjectId {
  local project_path=$1
  local project_id

  project_id=$("${GLPROJECTS}" --list-id --path "${project_path}")

  echo "Project ${project_path}=${project_id}" >&2
  if [ "${project_id}" = 'null' ]; then
      echo "*** ERROR: Can not create '${project_path}' project." >&2
      exit 1
  fi
  echo "${project_id}"
}

function run_tests {
  echo '#
# Create some groups
#'
  "${GLGROUPS}" --create --path audit_group_path1

  local group1_id
  group1_id=$(getGroupId audit_group_path1)

  "${GLGROUPS}" --create --path audit_group_path2

  local group2_id
  group2_id=$(getGroupId audit_group_path2)

  echo "group1_id=${group1_id}"
  echo "group2_id=${group2_id}"

  echo '#
# Create some projects
#'
  "${GLPROJECTS}" --create --group-id "${group1_id}" --path 'project_1_1'

  local project_1_1_id
  project_1_1_id=$(getProjectId project_1_1)

  "${GLPROJECTS}" --create --group-id "${group2_id}" --path 'project_2_1'

  local project_2_1_id
  project_2_1_id=$(getProjectId project_2_1)

  echo "project_1_1_id=${project_1_1_id}"
  echo "project_2_1_id=${project_2_1_id}"

  echo '#
# Audit - BEGIN
#'
  "${GLAUDIT}" --directory "${AUDIT_FOLDER}"

  echo '#
# Audit - END
#'

  echo '#
# Check Audit results
#'

  TMP_REF="${AUDIT_FOLDER}/tmp-${group1_id}-REF.json"
  TMP_AUDIT="${AUDIT_FOLDER}/tmp-${group1_id}-AUDIT.json"

  jq -S "setpath([\"id\"]; ${group1_id})" "${REFERENCES_HOME}/audit/audit_group_path1.json" > "${TMP_REF}"
  jq -S '.' "${AUDIT_FOLDER}/groups_by_id/${group1_id}.json" > "${TMP_AUDIT}"

  echo "Check DIFF with ref for: ${group1_id}"
  diff "${TMP_REF}" "${TMP_AUDIT}"
  if [ ! $? -eq 0 ]; then
    echo "*** ERROR: in result for group ${group1_id}"
    exit 1
  fi
  rm "${TMP_REF}" "${TMP_AUDIT}"

  TMP_REF="${AUDIT_FOLDER}/tmp-${group2_id}-REF.json"
  TMP_AUDIT="${AUDIT_FOLDER}/tmp-${group2_id}-AUDIT.json"

  jq -S "setpath([\"id\"]; ${group2_id})" "${REFERENCES_HOME}/audit/audit_group_path2.json" > "${TMP_REF}"
  jq -S '.' "${AUDIT_FOLDER}/groups_by_id/${group2_id}.json" > "${TMP_AUDIT}"

  echo "DIFF with ref for: ${group2_id}"
  diff "${TMP_REF}" "${TMP_AUDIT}"
  if [ ! $? -eq 0 ]; then
    echo "*** ERROR: in result for group ${group2_id}"
    exit 1
  fi
  rm "${TMP_REF}" "${TMP_AUDIT}"

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
}

run_tests


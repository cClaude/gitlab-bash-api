#!/bin/bash

source "$(dirname "$(realpath "$0")")/generated-config-bootstrap/init.sh"

declare -r GLGROUPS="${GITLAB_BASH_API_PATH}/glGroups.sh"
declare -r GLPROJECTS="${GITLAB_BASH_API_PATH}/glProjects.sh"

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-project.sh"

GROUP_PATH=group_for_$(echo "$0" | rev | cut -d'.' -f2- | cut -d'/' -f1 | rev )
declare -r GROUP_PATH=${GROUP_PATH}

PROJECT_PATH=project_for_$(echo "$0" | rev | cut -d'.' -f2- | cut -d'/' -f1 | rev )
declare -r PROJECT_PATH=${PROJECT_PATH}

function run_test {
  local group_id
  echo '-- CREATE GROUP (if needed) ----------------------'

  group_id=$("${GLGROUPS}" --list-id --path "${GROUP_PATH}")
  if [ -z "${group_id}" ]; then
    echo '-- CREATE GROUP ----------------------'
    "${GLGROUPS}" --create --path "${GROUP_PATH}"

    group_id=$("${GLGROUPS}" --list-id --path "${GROUP_PATH}")
  fi

  if [ -z "${group_id}" ]; then
    echo "*** Error can not create/retrieve group" >&2
    exit 1
  fi

  for project_id in $("${GLPROJECTS}" --list-id --group-path "${GROUP_PATH}"); do
    echo "project_id=${project_id}"
    "${GLPROJECTS}" --delete --id "${project_id}"
  done


  echo '-- CREATE PROJECT ----------------------'
  "${GLPROJECTS}" --create --group-id "${group_id}" --path "${PROJECT_PATH}"

  local project_id

  project_id=$("${GLPROJECTS}" --list-id --path "${PROJECT_PATH}")

   if [ -z "${project_id}" ]; then
     echo "*** Error can not create/retrieve project" >&2
     exit 1
   fi

  echo '-- EDIT PROJECT ----------------------'
  edit_project \
      id "${project_id}" \
      path "test-path-id-${project_id}" \
      name "test-name-id-${project_id}" \
        description "test description $(date)" \
      shared_runners_enabled 'false' \
      request_access_enabled false \
      public_builds false \
      | jq .

  echo '-- CLEANUP PROJECT ----------------------'
  "${GLPROJECTS}" --delete --id "${project_id}"

  echo '-- CLEANUP GROUP ----------------------'
  "${GLGROUPS}" --delete --id "${group_id}"

  echo '--'
}

run_test "$@"




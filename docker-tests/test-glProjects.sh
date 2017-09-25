#!/bin/bash

source "$(dirname $(realpath "$0"))/generated-config-bootstrap/init.sh"

declare -r GLGROUPS="${GITLAB_BASH_API_PATH}/glGroups.sh"
declare -r GLPROJECTS="${GITLAB_BASH_API_PATH}/glProjects.sh"

declare -r TEST_GROUP_PATH=group_for_tests

echo '#
# Create group
#'
"${GLGROUPS}" --create --path ${TEST_GROUP_PATH} --name "test group for test projects"

echo '#
# Display all groups names
#'
echo 'Group list - begin'
"${GLGROUPS}" --list-path --all
echo 'Group list - end'
group_id=$("${GLGROUPS}" --list-id --path ${TEST_GROUP_PATH})

echo "Group ID=${group_id}"

if [ "${group_id}" = 'null' ]; then
  echo '*** ERROR: Can not create initial group.'
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
"${GLPROJECTS}" --config --id "${project_id}"

echo '#
# Delete project
#'
"${GLPROJECTS}" --delete --id "${project_id}"

echo '#
# Delete group
#'
"${GLGROUPS}" --delete --id "${group_id}"

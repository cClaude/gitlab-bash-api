#!/bin/bash

source "$(dirname $(realpath "$0"))/generated-config-bootstrap/init.sh"

GLGROUPS="${GITLAB_BASH_API_PATH}/glGroups.sh"
GLPROJECTS="${GITLAB_BASH_API_PATH}/glProjects.sh"

#
# Group creation
#
"${GLGROUPS}" --create --path test_group_for_test_projects --name "test group for test projects"

#
# Display all groups names
#
echo 'Group list - begin'
"${GLGROUPS}" --list-path --all
echo 'Group list - end'
group_id=$("${GLGROUPS}" --list-id --path 'test_group_for_test_projects')

echo "Group ID=${group_id}"

#
# Project creation
#
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

echo 'Project list - begin'
"${GLPROJECTS}" --list-name --all
echo 'Project list - end'
project_id=$("${GLPROJECTS}" --list-id --path 'a_project_path')

echo "Project ID=${project_id}"

"${GLPROJECTS}" --delete --id "${project_id}"
"${GLGROUPS}" --delete --id "${group_id}"


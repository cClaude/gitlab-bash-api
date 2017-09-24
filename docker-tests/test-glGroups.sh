#!/bin/bash

source "$(dirname $(realpath "$0"))/generated-config-bootstrap/init.sh"

GLGROUPS="${GITLAB_BASH_API_PATH}/glGroups.sh"

function delete_group_by_path {
  local group_name=$1

  local group_id=$("${GLGROUPS}" --list-id --name "${group_name}")

  if [ "${group_id}" = 'null' ]; then
    echo "*** Can not find '${group_name}' => '${group_id}'" >&2
    exit 1
  else
    "${GLGROUPS}" --delete --id "${group_id}"
  fi
}

#
# Group creation
#
"${GLGROUPS}" --create --path test_group_path1
"${GLGROUPS}" --create --path test_group_path2 --name "test GROUP NAME 2" \
    --description "Test GROUP 4 DESCRIPTION" \
    --lfs_enabled true --membership_lock true --request_access_enabled true \
    --share_with_group_lock true --visibility  private
"${GLGROUPS}" --create --path test_group_path3 --name "test GROUP NAME 3" \
     --description "Test GROUP 3 DESCRIPTION" \
    --lfs_enabled false --membership_lock false --request_access_enabled false \
    --share_with_group_lock false --visibility  internal
"${GLGROUPS}" --create --path test_group_path4 --name "test GROUP NAME 4" \
     --description "Test GROUP 4 DESCRIPTION" \
    --lfs_enabled false --membership_lock true --request_access_enabled false \
    --share_with_group_lock true --visibility  public

#
# Display all groups names
#
"${GLGROUPS}" --list-name --all

#
# Edit group
#
TEST_GRP_ID=$("${GLGROUPS}" --list-id --name test_group_path4)

echo "EDIT"
#bash -ex
"${GLGROUPS}" --edit --id "${TEST_GRP_ID}" --name 'my_test_4_name' --path 'my_test_4_path' --visibility private

#
# Display group id
#
"${GLGROUPS}" --list-id --name 'my_test_4_path'


delete_group_by_path test_group_path1
delete_group_by_path test_group_path2
delete_group_by_path test_group_path3
delete_group_by_path my_test_4_path

#
# Display remaining groups ids
#
TST_GRP_LIST=$("${GLGROUPS}" --list-id --all)
echo "List='${TST_GRP_LIST}'"

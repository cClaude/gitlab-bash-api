#!/bin/bash

source "$(dirname "$(realpath "$0")")/generated-config-bootstrap/init.sh"

GLGROUPS=${GITLAB_BASH_API_PATH}/glGroups.sh
declare -r GLGROUPS=${GLGROUPS}

function delete_group_by_id {
  local group_id=$1

  echo "Try to delete group: '${group_id}' - path for this id is : '$("${GLGROUPS}" --list-path --id "${group_id}")'"

  "${GLGROUPS}" --delete --id "${group_id}"
}

function get_group_id_by_path {
  local group_path=$1
  local group_id

  group_id=$("${GLGROUPS}" --list-id --path "${group_path}")

  if [ -z "${group_id}" ]; then
    echo "* Warning: Can not find '${group_path}' => '${group_id}'" >&2
  elif [ "${group_id}" = 'null' ]; then
    echo "*** Error: --list-id --path '${group_path}' return null - should not occur." >&2
  else
    echo "${group_id}"
  fi
}

function delete_group_by_path {
  local group_path=$1
  local group_id

  group_id=$(get_group_id_by_path "${group_path}")

  if [ ! -z "${group_id}" ]; then
    delete_group_by_id "${group_id}"
  fi
}

function run_tests {
  echo '#
# Group creation
#'
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

  echo '#
# Display all groups names
#'
  "${GLGROUPS}" --list-path --all

  echo '#
# Edit group
#'
  TEST_GRP_ID=$(get_group_id_by_path test_group_path4)

  if [ -z "${TEST_GRP_ID}" ]; then
    echo "*** Error: Can not find group."
    exit 1
  fi

  "${GLGROUPS}" --edit --id "${TEST_GRP_ID}" --name 'my_test_4_name' --path 'my_test_4_path' --visibility private

  echo '#
# Display group id
#'
  "${GLGROUPS}" --list-id --path 'my_test_4_path'

  echo '#
# Delete groups
#'
  delete_group_by_path test_group_path1
  delete_group_by_path test_group_path2
  delete_group_by_path test_group_path3

  delete_group_by_path my_test_4_path
  echo "# Try to delete 'test_group_path4' that have been rename (should fail)"
  delete_group_by_path test_group_path4
  echo "# Try to delete 'test_group_path4' that is already deleted (should fail)"
  delete_group_by_id "${TEST_GRP_ID}"

  echo '#
# Display remaining groups ids
#'
  TST_GRP_LIST=$("${GLGROUPS}" --list-id --all)
  echo "List='${TST_GRP_LIST}'"
}

run_tests

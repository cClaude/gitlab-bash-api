#!/bin/bash

source "$(dirname "$(realpath "$0")")/generated-config-bootstrap/init.sh"
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"

function test_getErrorMessage {
  local json=$1
  local expected_result=$2
  local error_message

  error_message=$(getErrorMessage "${json}")

  echo "Msg='${error_message}' from '${json}'"
  if [ ! "${error_message}" = "${expected_result}" ]; then
    echo "*** Error expected '${expected_result}' - found '${error_message}'" >&2
    exit 1
  fi
}

test_getErrorMessage \
  '{"message": "404 Project Not Found"}' \
  '404 Project Not Found'

test_getErrorMessage \
  '' \
  ''

test_getErrorMessage \
  '[{"x":"y"}]' \
  ''

test_getErrorMessage \
  '{"id":1,"description":"Project ...","default_branch":"A","tag_list":[],"public":false,"archived":false,"visibility_level":10,"ssh_url_to_repo":"git@","http_url_to_repo":"http://","web_url":"http://X/Y/Z","name":"X","name_with_namespace":"Y / X","path":"X","path_with_namespace":"Y/X","container_registry_enabled":true,"issues_enabled":false,"merge_requests_enabled":true,"wiki_enabled":false,"builds_enabled":false,"snippets_enabled":false,"created_at":"xxxx","last_activity_at":"zzzzzz","shared_runners_enabled":true,"lfs_enabled":false,"creator_id":9,"namespace":{"id":32,"name":"Y","path":"Y","kind":"group"},"avatar_url":null,"star_count":0,"forks_count":0,"runners_token":"ZET","public_builds":true,"shared_with_groups":[],"only_allow_merge_if_build_succeeds":false,"request_access_enabled":true,"only_allow_merge_if_all_discussions_are_resolved":true,"approvals_before_merge":1,"permissions":{"project_access":{"access_level":40,"notification_level":3},"group_access":{"access_level":50,"notification_level":3}}}' \
  ''

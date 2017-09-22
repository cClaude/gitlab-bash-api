#!/bin/bash

# Configuration - BEGIN
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(dirname $(realpath "$0")))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
# Configuration - END


SAMPLE1='{"message": "404 Project Not Found"}'
SAMPLE2=''
SAMPLE3='[{"x":"y"}]'
SAMPLE4='{"id":149,"description":"Project ...","default_branch":"A","tag_list":[],"public":false,"archived":false,"visibility_level":10,"ssh_url_to_repo":"git@","http_url_to_repo":"http://","web_url":"http://X/puppet/X","name":"X","name_with_namespace":"puppet / X","path":"X","path_with_namespace":"puppet/X","container_registry_enabled":true,"issues_enabled":false,"merge_requests_enabled":true,"wiki_enabled":false,"builds_enabled":false,"snippets_enabled":false,"created_at":"2017-03-14T11:05:32.269Z","last_activity_at":"2017-09-22T12:58:01.125Z","shared_runners_enabled":true,"lfs_enabled":false,"creator_id":9,"namespace":{"id":32,"name":"puppet","path":"puppet","kind":"group"},"avatar_url":null,"star_count":0,"forks_count":0,"runners_token":"ZET","public_builds":true,"shared_with_groups":[],"only_allow_merge_if_build_succeeds":false,"request_access_enabled":true,"only_allow_merge_if_all_discussions_are_resolved":true,"approvals_before_merge":1,"permissions":{"project_access":{"access_level":40,"notification_level":3},"group_access":{"access_level":50,"notification_level":3}}}'

MSG1=$(getErrorMessage "${SAMPLE1}")
MSG2=$(getErrorMessage "${SAMPLE2}")
MSG3=$(getErrorMessage "${SAMPLE3}")
MSG4=$(getErrorMessage "${SAMPLE4}")

echo "SAMPLE1='${MSG1}'"
echo "SAMPLE2='${MSG2}'"
echo "SAMPLE3='${MSG3}'"
echo "SAMPLE4='${MSG4}'"

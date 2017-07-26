#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html#get-single-project
#
function display_usage {
  echo "Usage: $0 --all | --name PROJECT_NAME | --id PROJECT_ID [--raw]" >&2
  exit 100
}

# Configuration
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(realpath "$0"))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"

# Script start here
if [ $# -eq 0 ]; then
  display_usage
fi

# Parameters
PROJECT_ID=
PROJECT_NAME=
RAW=false

while [[ $# > 0 ]]
do
param="$1"
shift
case $param in
    -a|--all)
        ;;
        
    -n|--name)
        PROJECT_NAME="$1"
        shift
        ;;
        
    -i|--id)
        PROJECT_ID="$1"
        shift
        ;;
        
    -r|--raw)
        RAW=true
        ;;
        
    *)
        # unknown option
        display_usage
        ;;
esac
done

if [ "${RAW}" = "true" ] ; then
  answer=$(list_projects_raw "${PROJECT_ID}" '')
else
  answer=$(list_projects "${PROJECT_ID}" '')
fi

if [ -z "${PROJECT_NAME}" ] ; then
  echo "${answer}" | jq .
else 
  if [ "${RAW}" = "true" ] ; then
    JQ_FILTER="[.[] | select(.name==\"${PROJECT_NAME}\")]"
  else
    JQ_FILTER="[.[] | select(.project_name==\"${PROJECT_NAME}\")]"
  fi

  echo "${answer}" | jq "${JQ_FILTER}"
fi

# List all id
# ./listProjects.sh --all | jq '. [] | .id'

# List name and id
# ./listProjects.sh --all | jq '[ . [] | { project_name: .name, project_id: .id } ]'

# Number of projects visible for current user
# ./listProjects.sh --all | jq '. | length'

# 
# ./listProjects.sh --all | jq "[.[] | select(.group_name==\"${GROUP_NAME}\")]"
# ./listProjects.sh --all --raw | jq "[.[] | select(.namespace.path==\"${GROUP_NAME}\")]"


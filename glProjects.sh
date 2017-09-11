#!/bin/bash
#
# Documentation:
#   https://docs.gitlab.com/ce/api/projects.html#get-single-project
#
function display_usage {
  echo "Usage: $0" >&2
  echo "  List all projects" >&2
  echo "    $0 --all [--raw]" >&2
  echo "  List projects by name (could return many entries)" >&2
  echo "    $0 --name PROJECT_NAME [--raw]" >&2
  echo "  Get project configuration (by id)" >&2
  echo "    $0 --id PROJECT_ID [--raw]" >&2
  echo "  Delete a project" >&2
  echo "    $0 --delete --group GROUP_NAME --name PROJECT_NAME" >&2
  echo "    $0 --delete --id PROJECT_ID" >&2
  exit 100
}

# Configuration - BEGIN
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname $(realpath "$0"))
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
# Configuration - END

# Script start here
if [ $# -eq 0 ]; then
  display_usage
fi

# Parameters
PROJECT_ID=
PROJECT_NAME=
GROUP_NAME=
RAW=false
DELETE=false

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
    -g|--group)
        GROUP_NAME="$1"
        shift
        ;;
    -r|--raw)
        RAW=true
        ;;
    --delete)
        DELETE=true
        ;;
    *)
        # unknown option
        echo "Undefine parameter ${param}"
        display_usage
        ;;
esac
done

if [ "${DELETE}" = "true" ] ; then
  if [ -z "${PROJECT_ID}" ]; then
    ensure_not_empty "GROUP_NAME"
    ensure_not_empty "PROJECT_NAME"
    PROJECT_ID=$(get_project_id "${GROUP_NAME}" "${PROJECT_NAME}") || exit 1
  fi
  echo "# delete project: PROJECT_ID=[${PROJECT_ID}]" >&2

  answer=$(delete_projects_by_id "${PROJECT_ID}") || exit 1

  echo "${answer}"
  exit $?
fi

if [ "${RAW}" = "true" ] ; then
  JQ_FILTER="[.[] | select(.name==\"${PROJECT_NAME}\")]"
  answer=$(list_projects_raw "${PROJECT_ID}" 'statistics=true')
else
  JQ_FILTER="[.[] | select(.project_name==\"${PROJECT_NAME}\")]"
  answer=$(list_projects "${PROJECT_ID}" '')
fi

if [ -z "${PROJECT_NAME}" ] ; then
  echo "${answer}" | jq .
else
  echo "${answer}" | jq "${JQ_FILTER}"
fi

# List all id
# ./glProjects.sh --all | jq '. [] | .id'

# List name and id
# ./glProjects.sh --all | jq '[ . [] | { project_name: .name, project_id: .id } ]'

# Number of projects visible for current user
# ./glProjects.sh --all | jq '. | length'

#
# ./glProjects.sh --all | jq "[.[] | select(.group_name==\"${GROUP_NAME}\")]"
# ./glProjects.sh --all --raw | jq "[.[] | select(.namespace.path==\"${GROUP_NAME}\")]"


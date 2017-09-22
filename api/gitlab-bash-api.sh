#!/bin/bash
#
# GitLab bash API
#
# Based on GitLab documentation:
#  https://docs.gitlab.com/ee/api/
#  https://docs.gitlab.com/ce/api/
#  https://gitlab.com/gitlab-org/gitlab-ce/tree/master/lib/api
#  https://docs.gitlab.com/ce/api/projects.html
#
# Last version is available on GitHub: https://github.com/cClaude/gitlab-bash-api
#
NEXT_PAGE='*'

#
# HTTP GET - Read one page
#
function gitlab_get_page {
  local api_url="$1"
  local api_params="$2"
  local page="$3"

  local curl_url="${GITLAB_URL_PREFIX}/api/${GITLAB_API_VERSION}/${api_url}?page=${page}&per_page=${PER_PAGE_MAX}&${api_params}"
  local curl_result=$(curl --include --silent --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" "${curl_url}")
  local curl_rc=$?

  if [ $curl_rc -ne 0 ]; then
    echo "*** Error curl status ${curl_rc} : curl_url=${curl_url}" >&2
    return 1
  fi

  local head=true
  local body=
  local header=

  while read -r line; do
    if $head; then
      if [[ ${line} = $'\r' ]]; then
        head=false
      else
        header="${header}"$'\n'"${line}"
      fi
    else
      if [ -z "${body}" ]; then
        body="${line}"
      else
        body="${body}"$'\n'"${line}"
      fi
    fi
  done < <(echo "${curl_result}")

  NEXT_PAGE=$(echo "${header}" | grep 'X-Next-Page:' | cut -c 14-| tr -d '[:space:]')
  PAGE_BODY="${body}"
}

#
# HTTP GET - Read all pages
#
function gitlab_get {
  local api_url="$1"
  local api_params="$2"
  local page=1
  local json=
  local begin=

  while [[ ${page} =~ ^-?[0-9]+$ ]]; do
    gitlab_get_page "${api_url}" "${api_params}" "${page}"

    if [ ! -z "${json}" ] ; then
      json+=','
    fi

    begin=$(echo "${PAGE_BODY}" | cut -b1 )
    #echo "${begin}- ${page}" >>'body.txt'
    #echo "${PAGE_BODY}" >>'body.txt'
    if [ "${begin}" = '[' ] ; then
      json+=$(echo "${PAGE_BODY}" | cut -b2- | rev | cut -b2- | rev )
    else
      json+="${PAGE_BODY}"
    fi

     page="${NEXT_PAGE}"
  done

  if [ "${begin}" = '[' ] ; then
    echo "[${json}]"
  else
    echo "${json}"
  fi
}

#
# HTTP POST - Read 1st returned page
#
function gitlab_post {
  local api_url="$1"
  local api_params="$2"

  local curl_url="${GITLAB_URL_PREFIX}/api/${GITLAB_API_VERSION}/${api_url}?per_page=${PER_PAGE_MAX}&${api_params}"
  local curl_result=$(curl --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" -X POST --silent "${curl_url}")
  local curl_rc=$?

  if [ $curl_rc -ne 0 ]; then
    echo "*** Error curl status ${curl_rc} : curl_url=${curl_url}" >&2
    return 1
  fi

  echo "${curl_result}"
}

#
# HTTP PUT - Read 1st returned page
#
function gitlab_put {
  local api_url="$1"
  local api_params="$2"

  local curl_url="${GITLAB_URL_PREFIX}/api/${GITLAB_API_VERSION}/${api_url}?per_page=${PER_PAGE_MAX}&${api_params}"
  local curl_result=$(curl --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" -X PUT --silent "${curl_url}")
  local curl_rc=$?

  if [ $curl_rc -ne 0 ]; then
    echo "*** Error curl status ${curl_rc} : curl_url=${curl_url}" >&2
    return 1
  fi

  echo "${curl_result}"
}

#
# HTTP DELETE - Read 1st returned page
#
function gitlab_delete {
  local api_url="$1"
  local api_params="$2"

  local curl_url="${GITLAB_URL_PREFIX}/api/${GITLAB_API_VERSION}/${api_url}?per_page=${PER_PAGE_MAX}&${api_params}"
  local curl_result=$(curl --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" -X DELETE --silent "${curl_url}")
  local curl_rc=$?

  if [ $curl_rc -ne 0 ]; then
    echo "*** Error curl status ${curl_rc} : curl_url=${curl_url}" >&2
    return 1
  fi

  echo "${curl_result}"
}

function urlencode {
  # urlencode <string>
  old_lc_collate=$LC_COLLATE
  LC_COLLATE=C

  local length="${#1}"
  for (( i = 0; i < length; i++ )); do
    local c="${1:i:1}"
    case $c in
      [a-zA-Z0-9.~_-]) printf "$c" ;;
      *) printf '%%%02X' "'$c" ;;
    esac
  done

  LC_COLLATE=$old_lc_collate
}

function source_files {
  for f in $1/*
  do
    source "$f"
  done
}

function get_groupid_from_group_name {
  local group_name="$1"
  local answer=

  answer=$(gitlab_get "groups/${group_name}") || return 1

  local group_id=$(echo "${answer}" | jq .id)

  if [ -z "${group_id}" ] ; then
    echo "*** GROUP_NAME=[${group_name}] doest not exist - ${answer}" >&2
    exit 200
  fi

  if [ "${group_id}" = "null" ] ; then
    echo "*** GROUP_NAME=[${group_name}] doest not exist - ${answer}" >&2
    exit 201
  fi

  echo "${group_id}"
}

function list_projects_in_group {
  local group_name=$1

  answer=$(list_projects_raw)

  # Rewrite result
  local result_for_group=$(echo "${answer}" | jq "[.[] | select(.namespace.name==\"${group_name}\")]") || exit 301

  local size=$( echo "${result_for_group}" |jq '. | length' )

  if [ $size -eq 0 ] ; then
    echo "No project available for group [${group_name}] (group does not exist ?)" >&2
    exit 303
  fi

  echo "${result_for_group}" | jq -r ".[] | .path" || exit 302
}

function get_project_id {
  local group_name=$1
  local project_name=$2

  local answer=$(gitlab_get "projects" ) || exit 500
  local project_info=$(echo "${answer}" | jq -c ".[] | select( .path_with_namespace | contains(\"${group_name}/${project_name}\"))") || exit 1
  local project_id=$(echo "${project_info}" | jq -c ".id") || exit 501
  local valid_project_id=$(echo "${project_id}" | wc -l)

  if [ ${valid_project_id} -ne 1 ] ; then
    echo "*** More than one maching project: ${valid_project_id}" >&2
    exit 502
  fi

  if [ -z "${project_id}" ] ; then
    echo -e "** Project \"${group_name}/${project_name}\" does not exist" >&2
    exit 503
  fi

  echo "${project_id}"
}

function delete_projects_by_id {
  local project_id=$1

  local answer=$(gitlab_delete "projects/${project_id}") || exit 600
  if [ "${answer}" != "true" ] ; then
    echo "Can not delete project..." >&2
    echo "${answer}" >&2
    exit 601
  fi

  echo "${answer}"
}

function list_deploy_keys_raw {
  local project_id=$1
  local params=$2
  local answer=

  if [ -z "$project_id" ] ; then
    answer=$(gitlab_get "deploy_keys" "${params}") || exit 700
  else
    answer=$(gitlab_get "projects/${project_id}/deploy_keys" "${params}") || exit 701
  fi

  echo "${answer}"
}

function enable_deploy_keys {
  local project_id=$1
  local deploy_key_id=$2

  local answer=$(gitlab_post "/projects/${project_id}/deploy_keys/${deploy_key_id}/enable") || exit 702

  echo "${answer}"
}

function delete_deploy_keys {
  local project_id=$1
  local deploy_key_id=$2

  local answer=$(gitlab_delete "/projects/${project_id}/deploy_keys/${deploy_key_id}") || exit 703

  echo "${answer}"
}

function set_action {
  if [ -z "${ACTION}" ] ; then
     ACTION=$1
  else
    display_usage
  fi
}

# API : getErrorMessage

function getErrorMessage {
  local message=$(echo "$1" | jq -r '. .message' 2>/dev/null)

  if [ "${message}" = 'null' ]; then
    echo ''
  else
    echo "${message}"
  fi 
}

# API : ensure_not_empty (tooling)

function ensure_not_empty {
  local var_name=$1
  local var_value=${!var_name}

  if [ -z "${var_value}" ] ; then
    echo "Missing ${var_name} value" >&2
    display_usage
  fi
}

# API : ensure_not_empty (tooling)

function ensure_empty {
  local var_name=$1
  local var_value=${!var_name}

  if [ ! -z "${var_value}" ] ; then
     echo "Unexpected value ${var_name}=${var_value}" >&2
   display_usage
  fi
}

# API : ensure_boolean (tooling)

function ensure_boolean {
  local value=$1
  local parameter=$2
  
  case "${value}" in
    true|false)
      ;;
    *)
      echo "Bad value '${value}' for '${parameter}'. Should be true or false" >&2
      display_usage
      ;;
  esac
}

#
# Load configuration
#
source_files "${GITLAB_BASH_API_PATH}/config"

if [ -d "${GITLAB_BASH_API_PATH}/my-config" ]; then
  source_files "${GITLAB_BASH_API_PATH}/my-config"
fi

if [ ! -z "$GITLAB_BASH_API_CONFIG" ]; then
  if [ ! -d "${GITLAB_BASH_API_CONFIG}" ]; then
    echo "GITLAB_BASH_API_CONFIG=${GITLAB_BASH_API_CONFIG} - Folder not found." >&2
    exit 1
  fi

  source_files "${GITLAB_BASH_API_CONFIG}"
fi

#
# Check configuration
#
if [ -z "${GITLAB_PRIVATE_TOKEN}" ]; then
  echo "GITLAB_PRIVATE_TOKEN is missing." >&2
  exit 1
fi

if [ -z "${GITLAB_URL_PREFIX}" ]; then
  echo "GITLAB_URL_PREFIX is missing." >&2
  exit 1
fi

if [ -z "${PER_PAGE_MAX}" ]; then
  # Max value for GitLab is 100
  PER_PAGE_MAX=50
fi


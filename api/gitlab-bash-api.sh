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

declare -r LF=$'\n'
declare -r CR=$'\r'

declare NEXT_PAGE=

#
# HTTP GET - Read one page
#
function gitlab_get_page {
  local api_url="$1"
  local api_params="$2"
  local page="$3"

  local curl_url="${GITLAB_URL_PREFIX}/api/${GITLAB_API_VERSION}/${api_url}?page=${page}&per_page=${PER_PAGE_MAX}&${api_params}"
  local curl_result

  curl_result="$( curl --include --silent --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" "${curl_url}" )"
  local curl_rc=$?

  if [ ${curl_rc} -ne 0 ]; then
    echo "*** Error curl status ${curl_rc} : curl_url=${curl_url}" >&2
    return 1
  fi

  local head=true
  local body=
  local header=
  local line

  while read -r line; do
    if ${head} ; then
      if [[ "${line}" = "${CR}" ]]; then
        head=false
      else
        header="${header}${LF}${line}"
      fi
    else
      if [ -z "${body}" ]; then
        body="${line}"
      else
        body="${body}${LF}${line}"
      fi
    fi
  done < <(echo "${curl_result}")

  NEXT_PAGE="$( echo "${header}" | grep -i '^x-next-page:' | cut -c 14-| tr -d '[:space:]' )"
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

  NEXT_PAGE='*'

  while [[ ${page} =~ ^-?[0-9]+$ ]]; do
    gitlab_get_page "${api_url}" "${api_params}" "${page}"

    if [ -n "${json}" ] ; then
      json+=','
    fi

    begin=$(echo "${PAGE_BODY}" | cut -b1 )
    #echo "${begin}- ${page}" >>'body.txt'
    #echo "${PAGE_BODY}" >>'body.txt'
    if [ "${begin}" = '[' ] ; then
      json+="$( echo "${PAGE_BODY}" | cut -b2- | rev | cut -b2- | rev )"
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
# API: gitlab_post - HTTP POST - Read 1st returned page
#
function gitlab_post {
  local api_url="$1"
  local api_params="$2"

  local curl_url="${GITLAB_URL_PREFIX}/api/${GITLAB_API_VERSION}/${api_url}?per_page=${PER_PAGE_MAX}&${api_params}"
  local curl_result

  curl_result="$( curl --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" -X POST --silent "${curl_url}" )"
  local curl_rc=$?

  if [ ${curl_rc} -ne 0 ]; then
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
  local curl_result

  curl_result="$( curl --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" -X PUT --silent "${curl_url}" )"
  local curl_rc=$?

  if [ ${curl_rc} -ne 0 ]; then
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
  local curl_result

  curl_result="$( curl --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" -X DELETE --silent "${curl_url}" )"
  local curl_rc=$?

  if [ ${curl_rc} -ne 0 ]; then
    echo "*** Error curl status ${curl_rc} : curl_url=${curl_url}" >&2
    return 1
  fi

  echo "${curl_result}"
}

function url_encode {
  # url_encode <string>
  local LANG=C i c e=''
  for ((i=0;i<${#1};i++)); do
    c=${1:$i:1}
    # shellcheck disable=SC1001
    [[ "$c" =~ [a-zA-Z0-9\.\~\_\-] ]] || printf -v c '%%%02X' "'$c"
    e+="$c"
  done
  echo "$e"
}

function source_all_files_in_directory {
  local folder=$1
  local file

  for file in "${folder}"/* ; do
    source "${file}"
  done
}

function list_projects_in_group {
  local group_name=$1
  local answer

  answer="$( list_projects_raw )"

  # Rewrite result
  local result_for_group
  local size

  curl_result="$( echo "${answer}" | jq "[.[] | select(.namespace.name==\"${group_name}\")]" )" || exit $?
  size="$( echo "${result_for_group}" |jq '. | length' )"

  if [ "${size}" -eq 0 ] ; then
    echo "No project available for group [${group_name}] (group does not exist ?)" >&2
    exit 123
  fi

  echo "${result_for_group}" | jq -r ".[] | .path" || exit $?
}

function get_project_id {
  local group_name=$1
  local project_name=$2

  local answer
  local project_info
  local project_id
  local valid_project_id

  answer="$( gitlab_get "projects" )" || exit $?
  project_info="$( echo "${answer}" | jq -c ".[] | select( .path_with_namespace=\"${group_name}/${project_name}\")" )" || exit $?
  project_id="$( echo "${project_info}" | jq -c ".id" )" || exit $?
  valid_project_id="$( echo "${project_id}" | wc -l )"

  if [ "${valid_project_id}" -ne 1 ] ; then
    echo "*** More than one maching project: ${valid_project_id}" >&2
    exit 123
  fi

  if [ -z "${project_id}" ] ; then
    echo -e "** Project \"${group_name}/${project_name}\" does not exist" >&2
    exit 123
  fi

  echo "${project_id}"
}

function list_deploy_keys_raw {
  local project_id=$1
  local params=$2
  local answer=

  if [ -z "$project_id" ] ; then
    answer="$( gitlab_get "deploy_keys" "${params}" )" || exit $?
  else
    answer="$( gitlab_get "projects/${project_id}/deploy_keys" "${params}" )" || exit $?
  fi

  echo "${answer}"
}

function enable_deploy_keys {
  local project_id=$1
  local deploy_key_id=$2
  local answer

  answer="$( gitlab_post "/projects/${project_id}/deploy_keys/${deploy_key_id}/enable" )" || exit $?

  echo "${answer}"
}

function delete_deploy_keys {
  local project_id=$1
  local deploy_key_id=$2
  local answer

  answer="$( gitlab_delete "/projects/${project_id}/deploy_keys/${deploy_key_id}" )" || exit $?

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
  local message=
  message="$( echo "$1" | jq -r '. .message' 2>/dev/null )"

  if [ "${message}" = 'null' ]; then
    echo ''
  else
    echo "${message}"
  fi
}

# API : ensure_not_empty (tooling)

function ensure_not_empty {
  local value=$1
  local message_if_empty=$2

  if [ -z "${value}" ] ; then
    echo "*** Missing value for: '${message_if_empty}'" >&2
    display_usage
  fi
}

# DEPRECATED : ensure_not_empty_deprecated

function ensure_not_empty_deprecated {
  local var_name=$1
  local var_value=${!var_name}

  if [ -z "${var_value}" ] ; then
    echo "*** Missing ${var_name} value" >&2
    display_usage
  fi
}

# API : ensure_empty (tooling)

function ensure_empty {
  local value=$1
  local message_if_not_empty=$2

  if [ -n "${value}" ] ; then
    echo "Unexpected value '${value}': ${message_if_not_empty}" >&2
    display_usage
  fi
}

# DEPRECATED : ensure_empty_deprecated

function ensure_empty_deprecated {
  local var_name=$1
  local var_value=${!var_name}

  if [ -n "${var_value}" ] ; then
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

function jq_is_required {
  if which jq >/dev/null; then
    echo 'jq command is missing. Please install it.
  sudo apt install jq
or
  sudo yum install jq
' >&2
    exit 1
 fi
}

jq_is_required || exit 1
#
# Load configuration
#
source_all_files_in_directory "${GITLAB_BASH_API_PATH}/config"

if [ -d "${GITLAB_BASH_API_PATH}/my-config" ]; then
  source_all_files_in_directory "${GITLAB_BASH_API_PATH}/my-config"
fi

if [ -n "$GITLAB_BASH_API_CONFIG" ]; then
  if [ ! -d "${GITLAB_BASH_API_CONFIG}" ]; then
    echo "GITLAB_BASH_API_CONFIG=${GITLAB_BASH_API_CONFIG} - Folder not found." >&2
    exit 1
  fi

  source_all_files_in_directory "${GITLAB_BASH_API_CONFIG}"
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

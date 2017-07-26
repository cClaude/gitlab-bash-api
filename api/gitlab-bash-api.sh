#!/bin/bash
#
# GitLab bash API
#
# Last version is available on GitHub: https://github.com/cClaude/gitlab-bash-api
#
NEXT_PAGE='*'

#
# HTTP GET - Read one set of pages
#
function gitlab_get_page {
  local api_version="$1"
  local api_url="$2"
  local api_params="$3"
  local page="$4"

  local curl_url="${GITLAB_URL_PREFIX}/api/${api_version}/${api_url}?page=${page}&per_page=${PER_PAGE_MAX}&${api_params}"
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
  local api_version="$1"
  local api_url="$2"
  local api_params="$3"
  local page=1
  local json=
  local begin=

  while [[ ${page} =~ ^-?[0-9]+$ ]]; do
    gitlab_get_page "${api_version}" "${api_url}" "${api_params}" "${page}"

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
# HTTP POST - Read one set of pages
#
function gitlab_post {
  local api_version="$1"
  local api_url="$2"
  local api_params="$3"

  local curl_url="${GITLAB_URL_PREFIX}/api/${api_version}/${api_url}?per_page=${PER_PAGE_MAX}&${api_params}"
  local curl_result=$(curl --header "PRIVATE-TOKEN: ${GITLAB_PRIVATE_TOKEN}" -X POST --silent "${curl_url}")
  local curl_rc=$?

  if [ $curl_rc -ne 0 ]; then
    echo "*** Error curl status ${curl_rc} : curl_url=${curl_url}" >&2
    return 1
  fi

  echo "${curl_result}"
}

#
# HTTP DELETE - Read one set of pages
#
function gitlab_delete {
  local api_version="$1"
  local api_url="$2"
  local api_params="$3"

  local curl_url="${GITLAB_URL_PREFIX}/api/${api_version}/${api_url}?per_page=${PER_PAGE_MAX}&${api_params}"
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

function list_groups_raw {
  local group_id=$1
  local params=$2

  local answer=$(gitlab_get 'v3' "groups/${group_id}" "${params}") || exit 101
  echo "${answer}"
}

function list_projects_raw {
  local project_id=$1
  local params=$2

  local answer=$(gitlab_get 'v3' "projects/${project_id}" "${params}") || exit 102
  echo "${answer}"
}

function list_projects {
  local project_id=$1
  local params=$2
  local json=

  local answer=$(list_projects_raw "${project_id}" "${params}") || exit 103
  local begin=$(echo "${answer}" | cut -b1 )
  if [ "${begin}" = '[' ] ; then
    json="${answer}"
  else
    json="[${answer}]"
  fi

  #echo "${json}" >answer.json

  local short_result=$(echo "${json}" | jq '[.[] | {
project_id: .id,
project_name: .name,
project_path: .path,
group_name: .namespace.name,
path_with_namespace: .path_with_namespace,
ssh_url_to_repo: .ssh_url_to_repo,
http_url_to_repo: .http_url_to_repo,
container_registry_enabled: .container_registry_enabled,
issues_enabled: .issues_enabled,
merge_requests_enabled: .merge_requests_enabled,
wiki_enabled: .wiki_enabled,
builds_enabled: .builds_enabled,
snippets_enabled: .snippets_enabled,
shared_runners_enabled: .shared_runners_enabled,
lfs_enabled: .lfs_enabled,
request_access_enabled: .request_access_enabled
}]') || ext 104

  echo "${short_result}"
}

function get_groupid_from_group_name {
  local group_name="$1"
  local answer=

  answer=$(gitlab_get 'v3' "groups/${group_name}") || return 1

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
  
  answer=$(list_projects)

  # Rewrite result
  local result_for_group=$(echo "${answer}" | jq "[.[] | select(.group_name==\"${group_name}\")]") || exit 301

  local size=$( echo "${result_for_group}" |jq '. | length' )
  
  if [ $size -eq 0 ] ; then
    echo "No project available for [${group_name}]" >&2
    exit 303
  fi
  echo "${result_for_group}" | jq -r ".[] | .project_path" || exit 302
}

function get_project_urls {
  if [ "${URL_TYPE}" = "http" ] ; then
    if [ -z "${GITLAB_CLONE_HTTP_PREFIX}" ] ; then
      echo "*** GITLAB_CLONE_HTTP_PREFIX is not define" >&2
      exit 400
    fi
  else
    if [ -z "${GITLAB_CLONE_SSH_PREFIX}" ] ; then
      echo "*** GITLAB_CLONE_SSH_PREFIX is not define" >&2
      exit 401
    fi
  fi

  local project_paths=$(list_projects '' '' | jq -r '.[] | .path_with_namespace' ) || exit 402

  for p in ${project_paths}; do
    local project_path=$p
    local project_url

    if [ "${URL_TYPE}" = "http" ] ; then
      project_url="${GITLAB_CLONE_HTTP_PREFIX}/${project_path}.git"
    else
      project_url="${GITLAB_CLONE_SSH_PREFIX}:${project_path}.git"
    fi

    echo "${project_url}"
  done
}

function get_project_id {
  local group_name=$1
  local project_name=$2

  local answer=$(gitlab_get 'v3' "projects" ) || exit 500
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

  local answer=$(gitlab_delete 'v3' "projects/${project_id}") || exit 600
  if [ "${answer}" != "true" ] ; then
    echo "Can not delete project..." >&2
    echo "${answer}" >&2
    exit 601
  fi

  echo "${answer}"
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
if [ -z "$GITLAB_PRIVATE_TOKEN" ]; then
  echo "GITLAB_PRIVATE_TOKEN is missing." >&2
  exit 1
fi

if [ -z "$GITLAB_URL_PREFIX" ]; then
  echo "GITLAB_URL_PREFIX is missing." >&2
  exit 1
fi

if [ -z "$PER_PAGE_MAX" ]; then
  # Max value for GitLab is 100
  PER_PAGE_MAX=50
fi



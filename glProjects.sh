#!/bin/bash

function display_usage {
  echo "Usage: $0
  Get projects configuration
    $0 --config [--compact] --id PROJECT_ID
    $0 --config [--compact] --group-path GROUP_PATH
    $0 --config [--compact] --all
    $0 --config [--compact] --path PROJECT_PATH
  List projects paths
    $0 --list-path --id PROJECT_ID
    $0 --list-path --group-path GROUP_PATH (could return more than one entry)
    $0 --list-path --all
    $0 --list-path --path PROJECT_PATH (could return more than one entry)
  List projects ids
    $0 --list-id --id PROJECT_ID
    $0 --list-id --group-path GROUP_PATH (could return more than one entry)
    $0 --list-id --all
    $0 --list-id --path PROJECT_PATH
  Create project
    $0 --create --group-id GROUP_ID --path PROJECT_PATH \\
      [--project-name PROJECT_NAME] \\
      [--project-description PROJECT_DESCRIPTION] \\
      [--container-registry-enabled true|false] \\
      [--issues-enabled true|false] \\
      [--jobs-enabled true|false] \\
      [--lfs-enabled true|false] \\
      [--merge-requests-enabled true|false] \\
      [--only-allow-merge-if-all-discussions-are-resolved true|false] \\
      [--only-allow-merge-if-pipeline-succeed true|false] \\
      [--printing-merge-request-link-enabled true|false] \\
      [--public-jobs true|false] \\
      [--request-access-enabled true|false] \\
      [--snippets-enabled true|false] \\
      [--visibility private|internal|public] \\
      [--wiki-enabled true|false]
  Edit project
    $0 --edit --id PROJECT_ID --project-name PROJECT_NAME \\
      [--path PROJECT_PATH] \\
      [--default-branch DEFAULT_BRANCH]
      [--project-description PROJECT_DESCRIPTION] \\
      [--container-registry-enabled true|false] \\
      [--issues-enabled true|false] \\
      [--jobs-enabled true|false] \\
      [--lfs-enabled true|false] \\
      [--merge-requests-enabled true|false] \\
      [--only-allow-merge-if-all-discussions-are-resolved true|false] \\
      [--only-allow-merge-if-pipeline-succeed true|false] \\
      [--public-jobs true|false] \\
      [--request-access-enabled true|false] \\
      [--snippets-enabled true|false] \\
      [--visibility private|internal|public] \\
      [--wiki-enabled true|false]
  Edit project
    $0 --edit --id PROJECT_ID --project-name PROJECT_NAME \\
      [--path PROJECT_PATH] \\
      [--default-branch DEFAULT_BRANCH]
      [--project-description PROJECT_DESCRIPTION] \\
      [--issues-enabled true|false] \\
      [--merge-requests-enabled true|false] \\
      [--jobs-enabled true|false] \\
      [--wiki-enabled true|false] \\
      [--snippets-enabled true|false] \\
      [--container-registry-enabled true|false] \\
      [--visibility private|internal|public] \\
      [--public-jobs true|false] \\
      [--only-allow-merge-if-pipeline-succeed true|false] \\
      [--only-allow-merge-if-all-discussions-are-resolved true|false] \\
      [--lfs-enabled true|false] \\
      [--request-access-enabled true|false]
  Delete a project
    $0 --delete --group-path GROUP_PATH --path PROJECT_PATH
    $0 --delete --id PROJECT_ID
" >&2

  exit 100
}

function create_projects_handle_params {
  local group_id=${1}
  local project_path=${2}
  local project_name=${3}
  local project_description=${4}
  local p_container_registry_enabled=${5}
  local p_issues_enabled=${6}
  local p_jobs_enabled=${7}
  local p_lfs_enabled=${8}
  local p_merge_requests_enabled=${9}
  local p_only_allow_merge_if_all_discussions_are_resolved=${10}
  local p_only_allow_merge_if_pipeline_succeeds=${11}
  local p_printing_merge_request_link_enabled=${12}
  local p_public_jobs=${13}
  local p_request_access_enabled=${14}
  local p_snippets_enabled=${15}
  local p_visibility=${16}
  local p_wiki_enabled=${17}

  if [ -z "${group_id}" ]; then
    echo "* Parameter --group-id is missing" >&2
    display_usage
  fi
  if [ -z "${project_path}" ]; then
    echo "* Parameter --path is missing" >&2
    display_usage
  fi
  if [ -z "${p_container_registry_enabled}" ]; then
    p_container_registry_enabled="${GITLAB_DEFAULT_PROJECT_CONTAINER_REGISTRY_ENABLED}"
  fi
  if [ -z "${p_issues_enabled}" ]; then
    p_issues_enabled="${GITLAB_DEFAULT_PROJECT_ISSUES_ENABLED}"
  fi
  if [ -z "${p_jobs_enabled}" ]; then
    p_jobs_enabled="${GITLAB_DEFAULT_PROJECT_JOBS_ENABLED}"
  fi
  if [ -z "${p_lfs_enabled}" ]; then
    p_lfs_enabled="${GITLAB_DEFAULT_PROJECT_LFS_ENABLED}"
  fi
  if [ -z "${p_merge_requests_enabled}" ]; then
    p_merge_requests_enabled="${GITLAB_DEFAULT_PROJECT_MERGE_REQUESTS_ENABLED}"
  fi
  if [ -z "${p_only_allow_merge_if_all_discussions_are_resolved}" ]; then
    p_only_allow_merge_if_all_discussions_are_resolved="${GITLAB_DEFAULT_PROJECT_ONLY_ALLOW_MERGE_IF_ALL_DISCUSSIONS_ARE_RESOLVED}"
  fi
  if [ -z "${p_only_allow_merge_if_pipeline_succeeds}" ]; then
    p_only_allow_merge_if_pipeline_succeeds="${GITLAB_DEFAULT_PROJECT_ONLY_ALLOW_MERGE_IF_PIPELINE_SUCCEEDS}"
  fi
  if [ -z "${p_printing_merge_request_link_enabled}" ]; then
    p_printing_merge_request_link_enabled="${GITLAB_DEFAULT_PROJECT_PRINTING_MERGE_REQUEST_LINK_ENABLED}"
  fi
  if [ -z "${p_public_jobs}" ]; then
    p_public_jobs="${GITLAB_DEFAULT_PROJECT_PUBLIC_JOBS}"
  fi
  if [ -z "${p_request_access_enabled}" ]; then
    p_request_access_enabled="${GITLAB_DEFAULT_PROJECT_REQUEST_ACCESS_ENABLED}"
  fi
  if [ -z "${p_snippets_enabled}" ]; then
    p_snippets_enabled="${GITLAB_DEFAULT_PROJECT_SNIPPETS_ENABLED}"
  fi
  if [ -z "${p_visibility}" ]; then
    p_visibility="${GITLAB_DEFAULT_PROJECT_VISIBILITY}"
  fi
  if [ -z "${p_wiki_enabled}" ]; then
    p_wiki_enabled="${GITLAB_DEFAULT_PROJECT_WIKI_ENABLED}"
  fi

  ensure_boolean "${p_container_registry_enabled}" 'container_registry_enabled'
  ensure_boolean "${p_printing_merge_request_link_enabled}" 'printing_merge_request_link_enabled'

  create_project path "${project_path}" \
      container_registry_enabled "${p_container_registry_enabled}" \
      description "${project_description}" \
      issues_enabled "${p_issues_enabled}" \
      jobs_enabled "${p_jobs_enabled}" \
      lfs_enabled "${p_lfs_enabled}" \
      merge_requests_enabled "${p_merge_requests_enabled}" \
      name "${project_name}" \
      namespace_id "${group_id}" \
      only_allow_merge_if_all_discussions_are_resolved "${p_only_allow_merge_if_all_discussions_are_resolved}" \
      only_allow_merge_if_pipeline_succeeds "${p_only_allow_merge_if_pipeline_succeeds}" \
      printing_merge_request_link_enabled "${p_printing_merge_request_link_enabled}" \
      public_jobs "${p_public_jobs}" \
      request_access_enabled "${p_request_access_enabled}" \
      snippets_enabled "${p_snippets_enabled}" \
      visibility "${p_visibility}" \
      wiki_enabled "${p_wiki_enabled}"
}

# shellcheck disable=SC2086
function edit_project_handle_params {
  local id=${1}
  local name=${2}
  local path_defined=${3}
  local path=${4}
  local default_branch_defined=${5}
  local default_branch=${6}
  local description_defined=${7}
  local description=${8}
  local issues_enabled=${9}
  local merge_requests_enabled=${10}
  local jobs_enabled=${11}
  local wiki_enabled=${12}
  local snippets_enabled=${13}
  local container_registry_enabled=${14}
  local visibility=${15}
  local public_jobs=${16}
  local only_allow_merge_if_pipeline_succeeds=${17}
  local only_allow_merge_if_all_discussions_are_resolved=${18}
  local lfs_enabled=${19}
  local request_access_enabled=${20}
  #local shared_runners_enabled=
  #local resolve_outdated_diff_discussions=
  #local import_url=
  #local tag_list=
  #local avatar=
  #local ci_config_path=

  if [ -z "${id}" ]; then
    echo '* Parameter --id is mandatory' >&2
    display_usage
  fi
  if [ -z "${name}" ]; then
    echo '* Parameter --name is mandatory' >&2
    display_usage
  fi

  local edit_optional_parameters=

  if [ "${path_defined}" == true ]; then
    edit_optional_parameters+="path '${path}' "
  fi
  if [ "${default_branch_defined}" == true ]; then
    edit_optional_parameters+="default_branch '${default_branch}' "
  fi
  if [ "${description_defined}" == true ]; then
    edit_optional_parameters+="description \"${description}\" "
  fi
  if [ ! -z "${issues_enabled}" ]; then
    edit_optional_parameters+="issues_enabled '${issues_enabled}' "
  fi
  if [ ! -z "${merge_requests_enabled}" ]; then
    edit_optional_parameters+="merge_requests_enabled '${merge_requests_enabled}' "
  fi
  if [ ! -z "${jobs_enabled}" ]; then
    edit_optional_parameters+="jobs_enabled '${jobs_enabled}' "
  fi
  if [ ! -z "${wiki_enabled}" ]; then
    edit_optional_parameters+="wiki_enabled '${wiki_enabled}' "
  fi
  if [ ! -z "${snippets_enabled}" ]; then
    edit_optional_parameters+="snippets_enabled '${snippets_enabled}' "
  fi
  if [ ! -z "${container_registry_enabled}" ]; then
    edit_optional_parameters+="container_registry_enabled '${container_registry_enabled}' "
  fi
  if [ ! -z "${visibility}" ]; then
    edit_optional_parameters+="visibility '${visibility}' "
  fi
  if [ ! -z "${public_jobs}" ]; then
    edit_optional_parameters+="public_jobs '${public_jobs}' "
  fi
  if [ ! -z "${only_allow_merge_if_pipeline_succeeds}" ]; then
    edit_optional_parameters+="only_allow_merge_if_pipeline_succeeds '${only_allow_merge_if_pipeline_succeeds}' "
  fi
  if [ ! -z "${only_allow_merge_if_all_discussions_are_resolved}" ]; then
    edit_optional_parameters+="only_allow_merge_if_all_discussions_are_resolved '${only_allow_merge_if_all_discussions_are_resolved}' "
  fi
  if [ ! -z "${lfs_enabled}" ]; then
    edit_optional_parameters+="lfs_enabled '${lfs_enabled}' "
  fi
  if [ ! -z "${request_access_enabled}" ]; then
    edit_optional_parameters+="request_access_enabled '${request_access_enabled}' "
  fi

  eval edit_project 'id' "${id}" 'name' "'${name}'" ${edit_optional_parameters}
}

function show_projects_config_handle_params {
  local param_raw_display=$1
  local param_all=$2
  local param_project_id=$3
  local param_group_path=$4
  local param_project_path=$5

  if [ ! $# -eq 5 ]; then
    echo "* show_projects_config_handle_params: Expecting 5 parameters found $# : '$*'" >&2
    exit 1
  fi

  ensure_boolean "${param_raw_display}" 'param_raw_display' || exit 1
  ensure_boolean "${param_all}" 'param_all' || exit 1

  #DEBUG echo "### show_project_config '$1' - '$2' - '$3' - '$4' - '$5'" >&2

  # handle project id !!!!
  local answer

  answer=$(show_project_config "${param_raw_display}" "${param_project_id}") || exit 1

  local jq_filter=

  if [ "${param_raw_display}" = "true" ] ; then
    if [ ! -z "${param_group_path}" ]; then
      jq_filter="[.[] | select(.namespace.path==\"${param_group_path}\")]"
    elif [ ! -z "${param_project_path}" ]; then
      jq_filter="[.[] | select(.path==\"${param_project_path}\")]"
    elif [ "${param_all}" = "true" ] ; then
      jq_filter='.'
    elif [ ! -z "${param_project_id}" ] ; then
      jq_filter='.'
    else
      echo "Missing PROJECT_ID, GROUP_PATH, PROJECT_PATH or ALL parameter" >&2
      display_usage
    fi
  else
    if [ ! -z "${param_group_path}" ]; then
      jq_filter="[.[] | select(.group_path==\"${param_group_path}\")]"
    elif [ ! -z "${param_project_path}" ]; then
      jq_filter="[.[] | select(.project_path==\"${param_project_path}\")]"
    elif [  "${param_all}" = "true" ] ; then
      jq_filter='.'
    elif [ ! -z "${param_project_id}" ] ; then
      jq_filter='.'
    else
      echo "Missing PROJECT_ID, GROUP_PATH, PROJECT_PATH or ALL parameter" >&2
      display_usage
    fi
  fi

  local result
  local size=

  result=$(echo "${answer}" |jq "${jq_filter}" ) || exit 1

  if [ -z "${result}" ]; then
    size=0
  else
    size=$(echo "${result}" |jq '. | length' ) || exit 1
  fi

  if [ "${size}" -eq 0 ] ; then
    echo "* No project available." >&2
  fi

  echo "${result}"
}

function list_projects_paths_handle_params {
  local param_raw_display=$1
  local answer
  local jq_filter=

  answer=$(show_projects_config_handle_params "$@")

  if [ "${param_raw_display}" = "true" ] ; then
    jq_filter='.[] | .path'
  else
    jq_filter='.[] | .project_path'
  fi

  echo "${answer}" | jq -r "${jq_filter}"
}

function list_projects_ids_handle_params {
  local param_raw_display=$1
  local answer
  local jq_filter=

  answer=$(show_projects_config_handle_params "$@")

  if [ "${param_raw_display}" = "true" ] ; then
    jq_filter='.[] | .id'
  else
    jq_filter='.[] | .project_id'
  fi

  echo "${answer}" | jq -r "${jq_filter}"
}

function delete_project_handle_params {
  local param_project_id=$1
  local param_group_name=$2
  local param_project_name=$3

  local project_id=

  if [ -z "${param_project_id}" ]; then
    ensure_not_empty_deprecated 'param_group_name'
    ensure_not_empty_deprecated 'param_project_name'

    project_id=$(get_project_id "${param_group_name}" "${param_project_name}") || exit 1
  else
    project_id=${param_project_id}
  fi

  delete_project "${project_id}"
}

function main {
  local param_all=false
  local param_group_id=
  local param_group_path=
  local param_project_id=
  local param_project_path_define=
  local param_project_path=
  local param_raw_display=true
  local p_container_registry_enabled=
  local p_issues_enabled=
  local p_jobs_enabled=
  local p_lfs_enabled=
  local p_merge_requests_enabled=
  local p_only_allow_merge_if_all_discussions_are_resolved=
  local p_only_allow_merge_if_pipeline_succeeds=
  local p_printing_merge_request_link_enabled=
  local p_project_description_define=
  local p_project_description=
  local p_project_name=
  local p_public_jobs=
  local p_request_access_enabled=
  local p_snippets_enabled=
  local p_visibility=
  local p_wiki_enabled=
  local action=
  local p_default_branch=

  while [[ $# -gt 0 ]]; do
    local param="$1"
    shift

    case "${param}" in
      -a|--all)
        param_all=true
        ;;
      --compact)
        param_raw_display=false
        ;;
      --container-registry-enabled)
        p_container_registry_enabled="$1"
        ensure_boolean "${p_container_registry_enabled}" '--container-registry-enabled'
        shift
        ;;
      --create)
        ensure_empty_deprecated action
        action=createAction
        ;;
      --config)
        ensure_empty_deprecated action
        action=showConfigAction
        ;;
      --delete)
        ensure_empty_deprecated action
        action=deleteAction
        ;;
      --edit)
        ensure_empty_deprecated action
        action=editAction
        ;;
      --group-id)
        param_group_id="$1"
        shift
        ;;
      -g|--group-path)
        param_group_path="$1"
        shift
        ;;
      -i|--id)
        param_project_id="$1"
        shift
        ;;
      --issues-enabled)
        p_issues_enabled="$1"
        ensure_boolean "${p_issues_enabled}" '--issues-enabled'
        shift
        ;;
      --jobs-enabled)
        p_jobs_enabled="$1"
        ensure_boolean "${p_jobs_enabled}" '--jobs-enabled'
        shift
        ;;
      --lfs-enabled)
        p_lfs_enabled="$1"
        ensure_boolean "${p_lfs_enabled}" '--lfs-enabled'
        shift
        ;;
      --list-path)
        ensure_empty_deprecated action
        action=listPathsAction
        ;;
      --list-id)
        ensure_empty_deprecated action
        action=listIdsAction
        ;;
      -p|--path|--project-path)
        param_project_path="$1"
        param_project_path_define=true
        shift
        ;;
      --merge-requests-enabled)
        p_merge_requests_enabled="$1"
        ensure_boolean "${p_merge_requests_enabled}" '--merge-requests-enabled'
        shift
        ;;
      --only-allow-merge-if-all-discussions-are-resolved)
        p_only_allow_merge_if_all_discussions_are_resolved="$1"
        ensure_boolean "${p_only_allow_merge_if_all_discussions_are_resolved}" '--only-allow-merge-if-all-discussions-are-resolved'
        shift
        ;;
      --only-allow-merge-if-pipeline-succeed)
        p_only_allow_merge_if_pipeline_succeeds="$1"
        ensure_boolean "${p_only_allow_merge_if_pipeline_succeeds}" '--only-allow-merge-if-pipeline-succeed'
        shift
        ;;
      --printing-merge-request-link-enabled)
        p_printing_merge_request_link_enabled="$1"
        ensure_boolean "${p_printing_merge_request_link_enabled}" '--printing-merge-request-link-enabled'
        shift
        ;;
      --project-description)
        p_project_description="$1"
        p_project_description_define=true
        shift
        ;;
      --project-name)
        p_project_name="$1"
        shift
        ;;
      --public-jobs)
        p_public_jobs="$1"
        ensure_boolean "${p_public_jobs}" '--public-jobs'
        shift
        ;;
      --request-access-enabled)
        p_request_access_enabled="$1"
        ensure_boolean "${p_request_access_enabled}" '--request-access-enabled'
        shift
        ;;
      --snippets-enabled)
        p_snippets_enabled="$1"
        ensure_boolean "${p_snippets_enabled}" '--snippets-enabled'
        shift
        ;;
      --visibility)
        p_visibility="$1"
        shift

        case "${p_visibility}" in
           private|internal|public)
             ;;
           *)
             echo "Illegal value '${p_visibility}'. --visibility should be private, internal or public." >&2
             display_usage
             ;;
        esac
        ;;
      --wiki-enabled)
        p_wiki_enabled="$1"
        ensure_boolean "${p_wiki_enabled}" '--wiki-enabled'
        shift
        ;;
      --default-branch)
        p_default_branch="$1"
        p_default_branch_defined=true
        shift
        ;;
      *)
        # unknown option
        echo "Unknown parameter ${param}" >&2
        action=
        display_usage
        ;;
    esac
  done

  case "${action}" in
    createAction)
        create_projects_handle_params "${param_group_id}" "${param_project_path}" "${p_project_name}" \
          "${p_project_description}" "${p_container_registry_enabled}" "${p_issues_enabled}" \
          "${p_jobs_enabled}" "${p_lfs_enabled}" "${p_merge_requests_enabled}" \
          "${p_only_allow_merge_if_all_discussions_are_resolved}" \
          "${p_only_allow_merge_if_pipeline_succeeds}" \
          "${p_printing_merge_request_link_enabled}" \
          "${p_public_jobs}" "${p_request_access_enabled}" "${p_snippets_enabled}" \
          "${p_visibility}" "${p_wiki_enabled}" \
          | jq .
        ;;
    deleteAction)
        delete_project_handle_params "${param_project_id}" "${param_group_path}" "${param_project_path}" | jq .
        ;;
    editAction)
        edit_project_handle_params "${param_project_id}" "${p_project_name}" \
            "${param_project_path_define}" "${param_project_path}" \
            "${p_default_branch_defined}" "${p_default_branch}" \
            "${p_project_description_define}" "${p_project_description}" \
            "${p_issues_enabled}" \
            "${p_merge_requests_enabled}" \
            "${p_jobs_enabled}" \
            "${p_wiki_enabled}" \
            "${p_snippets_enabled}" \
            "${p_container_registry_enabled}" \
            "${p_visibility}" \
            "${p_public_jobs}" \
            "${p_only_allow_merge_if_pipeline_succeeds}" \
            "${p_only_allow_merge_if_all_discussions_are_resolved}" \
            "${p_lfs_enabled}" \
            "${p_request_access_enabled}" \
            | jq .
        ;;
    listPathsAction)
        list_projects_paths_handle_params "${param_raw_display}" "${param_all}" "${param_project_id}" "${param_group_path}" "${param_project_path}"
        ;;
    listIdsAction)
        list_projects_ids_handle_params "${param_raw_display}" "${param_all}" "${param_project_id}" "${param_group_path}" "${param_project_path}"
        ;;
    showConfigAction)
        show_projects_config_handle_params "${param_raw_display}" "${param_all}" \
            "${param_project_id}" "${param_group_path}" "${param_project_path}" \
            | jq .
        ;;
    *)
        # unknown option
        echo "Missing --config, --list-name, --list-id, --edit or --delete * ${action}" >&2
        display_usage
        ;;
  esac
}

# Configuration - BEGIN
if [ -z "$GITLAB_BASH_API_PATH" ]; then
  GITLAB_BASH_API_PATH=$(dirname "$(realpath "$0")")
fi

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"
# Configuration - END

# Script start here
source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api-project.sh"

if [ $# -eq 0 ]; then
  display_usage
fi

main "$@"

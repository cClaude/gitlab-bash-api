#!/bin/bash

function getSessionForUser {

  # Verify configuration
  if [ -z "${GITLAB_URL_PREFIX}" ]; then
    echo "** GITLAB_URL_PREFIX is missing."
    exit 1
  fi
  if [ -z "${GITLAB_API_VERSION}" ]; then
    echo "** GITLAB_API_VERSION is missing."
    exit 1
  fi
  if [ -z "${GITLAB_USER}" ]; then
    echo "** GITLAB_USER is missing."
    exit 1
  fi
  if [ -z "${GITLAB_PASSWORD}" ]; then
    echo "** GITLAB_PASSWORD is missing."
    exit 1
  fi

  local url="${GITLAB_URL_PREFIX}/api/${GITLAB_API_VERSION}/session"

  echo "# Try to build GitLab Session from ${url}" >&2

  curl --silent  --data "login=${GITLAB_USER}&password=${GITLAB_PASSWORD}" ${url} || exit 1
}

# gain a gitlab token for user
function getTokenForUser {
  local session=$(getSessionForUser)
  local token=$(echo "${session}" | jq --raw-output '. .private_token')

  if [ ! -z "${token}" ]; then
    echo "${token}"
  else
    local error_msg=$(getErrorMessage "${session}")
    echo "*** Error: Can not get token from GitLab: '${error_msg}'" >&2

    if [ -z "${error_msg}" ] ; then
      echo "${session}" | jq . >&2
    elif [ "${error_msg}" = '401 Unauthorized' ]; then
      echo "You need need to log once in GitLab ?" >&2
    fi

    exit 1
  fi
}

function generate_gitlab_token_configuration_file {
  local token_configuration_file="$1"
  local token="$2"

  echo "Create/Update '${token_configuration_file}'" >&2
  echo "#!/bin/bash

GITLAB_PRIVATE_TOKEN=${token}
" >"${token_configuration_file}"
}

DOCKER_GITLAB_HOME_PATH=$(realpath "$(dirname "$(dirname "$(realpath "$0")")")")

GITLAB_BASH_API_CONFIG=${DOCKER_GITLAB_HOME_PATH}/gitlab-bash-api-config-for-docker
GITLAB_BASH_API_CONFIG_FOLDER="${GITLAB_BASH_API_CONFIG}/"

source "${DOCKER_GITLAB_HOME_PATH}/generated-config-bootstrap/init.sh"

if [ ! -f "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh" ]; then
  echo "gitlab-bash-api.sh not found! - Please set GITLAB_BASH_API_PATH" >&2
  exit 1
fi

source "${GITLAB_BASH_API_PATH}/api/gitlab-bash-api.sh"

declare -r GENERATE_PRIVATE_TOKEN_FILE=${GITLAB_BASH_API_CONFIG_FOLDER}generate-private-token

echo "Look for configuration into '${GITLAB_BASH_API_CONFIG_FOLDER}'" >&2

if [ ! -d "${GITLAB_BASH_API_CONFIG_FOLDER}" ] ; then
  echo "*** Can not find configuration folder: '${GITLAB_BASH_API_CONFIG_FOLDER}'" >&2
  exit 1
fi

for file in $(find "${GITLAB_BASH_API_CONFIG_FOLDER}" -type f); do

  if [ "${file}" = "${GENERATE_PRIVATE_TOKEN_FILE}" ]; then
    echo "Skip '${file}'" >&2
  else
    echo "Use configuration in '${file}'" >&2

    source "${file}"
  fi
done

# gain a gitlab token for user
TOKEN=$(getTokenForUser)
if [ -z "${TOKEN}" ]; then
  exit 1
else
  generate_gitlab_token_configuration_file "${GENERATE_PRIVATE_TOKEN_FILE}" "${TOKEN}"
fi

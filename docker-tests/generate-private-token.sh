#!/bin/bash

GITLAB_BASH_API_CONFIG=$(realpath $(dirname $(realpath "$0"))/gitlab-bash-api-config-for-docker)
GITLAB_BASH_API_CONFIG_FILE="${GITLAB_BASH_API_CONFIG}/"

for file in $(find "${GITLAB_BASH_API_CONFIG_FILE}" -type f); do
  echo "Use configuration in '${file}'" >&2

  source "${file}"
done

#gain a gitlab token
GITLAB__SESSION_URL="${GITLAB_URL_PREFIX}/api/${GITLAB_API_VERSION}/session"

echo "# GITLAB__SESSION_URL=${GITLAB__SESSION_URL}" >&2

SESSION=$(curl --silent  --data "login=${GITLAB_USER}&password=${GITLAB_PASSWORD}" ${GITLAB__SESSION_URL}) || exit 1

TOKEN=$(echo "${SESSION}" | jq --raw-output .private_token)

echo "#!/bin/bash

GITLAB_PRIVATE_TOKEN=${TOKEN}
" >"${GITLAB_BASH_API_CONFIG_FILE}/generate-private-token"

echo "${SESSION}" | jq .

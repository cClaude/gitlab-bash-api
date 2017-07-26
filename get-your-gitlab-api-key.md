# How to get your GitLab API key

```bash
#!/bin/bash

#
# Need: GITLAB_HOST, GITLAB_PORT, GITLAB_USER and GITLAB_PASSWORD
#
GITLAB_HOST=
GITLAB_PORT=
GITLAB_USER=
GITLAB_PASSWORD=

GITLAB_URL_PREFIX="http://${GITLAB_HOST}:${GITLAB_PORT}"

#gain a gitlab token
GITLAB__SESSION_URL="${GITLAB_URL_PREFIX}/api/v3/session"
SESSION=$(curl --silent  --data "login=${GITLAB_USER}&password=${GITLAB_PASSWORD}" ${GITLAB__SESSION_URL}) || exit 1

echo "${SESSION}" | jq --raw-output .private_token 
```


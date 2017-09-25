#!/bin/bash

# https://docs.gitlab.com/omnibus/docker/README.html

source "$(dirname $(realpath "$0"))/generated-config-bootstrap/init.sh"

if [ -z "${DOCKER_GITLAB_CONFIGURATION_FILE}" ]; then
  echo "*** DOCKER_GITLAB_CONFIGURATION_FILE: Not initialize (run setup-configuration.sh to fix this)" >&2
  exit 1
fi
if [ ! -f "${DOCKER_GITLAB_CONFIGURATION_FILE}" ]; then
  echo "*** DOCKER_GITLAB_CONFIGURATION_FILE='${DOCKER_GITLAB_CONFIGURATION_FILE}' not found" >&2
  exit 1
fi
source "${DOCKER_GITLAB_CONFIGURATION_FILE}"

sudo docker run --detach \
    --hostname "${DOCKER_HOSTNAME}" \
    --publish 443:443 --publish ${DOCKER_HTTP_PORT}:80 --publish ${DOCKER_SSH_PORT}:22 \
    --name "${DOCKER_NAME}" \
    --restart no \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    gitlab/gitlab-ce:latest
docker_run_rc=$?

if [ ${docker_run_rc} -eq 125 ]; then
  echo 'Already running -> try to restart'

  sudo docker restart gitlab
fi


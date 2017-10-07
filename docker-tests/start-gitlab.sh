#!/bin/bash

# https://docs.gitlab.com/omnibus/docker/README.html

source "$(dirname $(realpath "$0"))/generated-config-bootstrap/init.sh"

sudo docker run --detach \
    --hostname "${DOCKER_GITLAB_HTTP_HOST}" \
    --publish 443:443 --publish ${DOCKER_HTTP_PORT}:80 --publish ${DOCKER_SSH_PORT}:22 \
    --name "${DOCKER_NAME}" \
    --restart no \
    --volume /srv/gitlab/config:/etc/gitlab \
    --volume /srv/gitlab/logs:/var/log/gitlab \
    --volume /srv/gitlab/data:/var/opt/gitlab \
    "${DOCKER_GITLAB_VERSION}"
docker_run_rc=$?

if [ ${docker_run_rc} -ne 0 ]; then
  echo "*** docker run error :  ${docker_run_rc}" >&2
fi
if [ ${docker_run_rc} -eq 125 ]; then
  echo 'Already running -> try to restart' >&2

  sudo docker restart gitlab
fi

echo "
To upgrade gitlab or change version (current version '${DOCKER_GITLAB_VERSION}')
or all to have cache all versions locally.
  sudo docker pull gitlab/gitlab-ce:latest
  sudo docker pull gitlab/gitlab-ce:rc
  sudo docker pull gitlab/gitlab-ee:latest
  sudo docker pull gitlab/gitlab-ee:rc

then stop and remove the existing container:
  sudo docker stop "${DOCKER_NAME}"; sudo docker rm "${DOCKER_NAME}"

finally start the container as you did originally.
  $0
"

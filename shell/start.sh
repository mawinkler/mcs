#!/bin/bash
MCS_VERSION=$(cat .MCS_VERSION)
PORT=2222

printf '%s\n' "Starting Multi Cloud Shell"
docker run \
  --detach \
  --rm \
  --name=mcs-${MCS_VERSION} \
  --env TZ=Europe/Berlin \
  --env DEBIAN_FRONTEND=noninteractive \
  --publish ${PORT}:22 \
  --volume $(pwd)/workdir:/home/mcs \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  mcs:${MCS_VERSION}

printf '%s\n' "Connect:  ssh -p ${PORT} mcs@$(hostname -I | awk '{print $1}')"
printf '%s\n' "Password: mcs"

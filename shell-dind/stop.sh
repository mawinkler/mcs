#!/bin/bash
CONTAINER=$(docker ps --format "{{.Names}}" | grep mcs-dind)
docker stop ${CONTAINER} && \
  docker rm $(docker ps -a --format "{{.Names}}" | grep mcs-dind)

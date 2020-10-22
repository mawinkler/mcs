#!/bin/bash
CONTAINER=$(docker ps --format "{{.Names}}" | grep mcs)
docker stop ${CONTAINER} && \
  docker rm $(docker ps -a --format "{{.Names}}" | grep mcs)

#!/bin/bash
CONTAINER=$(docker ps --format "{{.ID}}" --filter "name=mcs")
docker stop ${CONTAINER} && \
  docker rm $(docker ps -a --format "{{.Names}}" | grep mcs)

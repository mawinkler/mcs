#!/bin/bash
MCS_VERSION=$(cat .MCS_VERSION)
CONTAINER=$(docker ps --format "{{.ID}}" --filter "name=mcs-${MCS_VERSION}")

docker stop ${CONTAINER}

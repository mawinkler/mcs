#!/bin/bash
MCS_VERSION=$(cat .MCS_VERSION)
CONTAINER=$(docker ps --format "{{.ID}}" --filter "name=mcs")

if [ ${CONTAINER} ]
then
  echo Attaching to Running Instance
  docker attach ${CONTAINER}
else
  echo Creating new Instance
  docker-compose run mcs
fi

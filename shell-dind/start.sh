#!/bin/bash
CONTAINER=$(docker ps --format "{{.Names}}" | grep mcs-dind)

if [ ${CONTAINER} ]
then
  echo Attaching to Running Instance
  docker attach ${CONTAINER}
else
  echo Creating new Instance
  docker-compose run mcs-dind
fi

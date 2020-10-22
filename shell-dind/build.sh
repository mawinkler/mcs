#!/bin/bash
echo "Generating Environment File"
echo "UID=$(id -u)" > .env
echo "GID=$(id -g)" >> .env

#echo "Building Multi Cloud Shell Container Image"
docker-compose build mcs-dind

IMAGE=$(docker images --format "{{.Repository}}" | grep mcs-dind)
echo "Starting Multi Cloud Shell Container from image ${IMAGE}"
docker run -d --rm --name=mcs-dind ${IMAGE} /bin/sleep 60

echo "Fetch Home Directory from Container"
CONTAINER=$(docker ps --format "{{.Names}}" | grep mcs-dind)
docker cp ${CONTAINER}:/tmp/home.tgz .

echo "Stopping Multi Cloud Shell Container"
docker stop ${CONTAINER}

echo "Populating workdir"
mkdir -p workdir
tar xpzf home.tgz --strip-components=2 -C ./workdir
rm home.tgz

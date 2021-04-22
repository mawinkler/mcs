#!/bin/bash
echo "Generating Environment File"
echo "UID=$(id -u)" > .env
echo "GID=$(id -g)" >> .env

rm -f home.tgz

docker-compose build mcs

IMAGE=$(docker images --format "{{.Repository}}" | grep mcs)
echo "Starting Multi Cloud Shell Container from image ${IMAGE}"
docker run -d --rm --name=mcs ${IMAGE} -c "/bin/sleep 60"

echo "Fetch Home Directory from Container"
CONTAINER=$(docker ps --format "{{.Names}}" | grep mcs)
docker cp ${CONTAINER}:/tmp/home.tgz .

echo "Stopping Multi Cloud Shell Container"
docker stop ${CONTAINER}

echo "Populating workdir"
mkdir -p workdir
tar xpzf home.tgz --strip-components=2 -C ./workdir

rm -f home.tgz

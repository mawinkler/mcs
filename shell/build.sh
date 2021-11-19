#!/bin/bash
MCS_VERSION=$(cat .MCS_VERSION)

printf '%s\n' "Building mcs version ${MCS_VERSION}"
rm -f home.tgz

# docker-compose build mcs
docker build \
    -t mcs:${MCS_VERSION} \
    --build-arg uid=$(id -u) \
    --build-arg gid=$(id -g) \
    --build-arg version=${MCS_VERSION} \
    .

IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "mcs:${MCS_VERSION}")
printf '%s\n' "Starting Multi Cloud Shell Container from image ${IMAGE}"
docker run -d --rm --name=mcs-${MCS_VERSION} ${IMAGE} -c "/bin/sleep 60"

printf '%s\n' "Fetch Home Directory from Container"
CONTAINER=$(docker ps --format "{{.ID}}" --filter "name=mcs-${MCS_VERSION}")
docker cp ${CONTAINER}:/tmp/home.tgz .

printf '%s\n' "Stopping Multi Cloud Shell Container"
docker stop ${CONTAINER}

printf '%s\n' "Populating workdir"
mkdir -p workdir
tar xpzf home.tgz --strip-components=2 -C ./workdir

rm -f home.tgz

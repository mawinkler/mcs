# Multi Cloud Shell DinD

**ALPHA VERSION**

This repository provides a container image providing a multi cloud shell for AWS, Google and Azure. Additionally, it provides a built in docker engine and the most relevant tools to manage Kubernetes clusters. The core components of that image are:

* `gcloud` cli for Google
* `aws` cli for AWS
* `az` cli for Azure
* `dockerd` and `docker`
* plus all additional tools and command line interfaces to manage kubernetes clusters
  * kubectl
  * eksctl
  * helm3

I'm using a slightly different variant of supplying docker functionality within a container. DinD is realized here as a daemon of docker running inside the container.
This is a more isolated way. You can have a clean environment with docker every time you want. That way, we're getting rid of the common problems sharing sockets.

Persistence is provided by a mapped working directory on your docker host. That means, you can easily destroy and rebuild the image whenever needed. If you want to move your setup, simply tar / zip your local repo directory including the workdir.

## Prerequisites

Docker & Docker-Compose

Tested with

* Linux,
* Mac OS X with *Docker for Desktop* and

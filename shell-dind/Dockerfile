FROM ubuntu:18.04 AS base

ARG VERSION=0.1
ARG user=mcs
ARG group=mcs
ARG uid
ARG gid

ENV DOCKER_CHANNEL=stable \
	DOCKER_VERSION=19.03.11 \
	DOCKER_COMPOSE_VERSION=1.26.0 \
    DOCKER_ARCH='x86_64' \
	DEBUG=false

# Root context
RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone

RUN addgroup -gid ${gid} ${group} || true
RUN useradd -m -s /bin/bash -d /home/${user} -u ${uid} -g ${gid} ${user}

LABEL Description="This is the Multi Cloud Shell"

ARG WORKDIR=/home/${user}

COPY add-apt-repository /usr/bin

RUN \
    # Enable Universe Repo
    apt update && \
    apt install -y python3 python3-pip software-properties-common curl && \
    add-apt-repository universe && \
    \
    # Add Google Repo
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    \
    # Add Azure Repo
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
    export AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | tee /etc/apt/sources.list.d/azure-cli.list && \
    \
    # Add Helm Repo
    curl https://baltocdn.com/helm/signing.asc | apt-key add - && \
    apt-get install apt-transport-https --yes && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    \
    # Install Packages
    apt update && \
    apt install -y sudo vim nano jq figlet wget ssh git locales-all zip libffi6 libffi-dev libssl-dev ca-certificates apt-transport-https lsb-release gnupg && \
    \
    # Google
    apt install -y google-cloud-sdk && \
    apt install -y azure-cli && \
    \
    # Kubectl
    apt install -y kubectl && \
    \
    # Eksctl
    curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
    mv -v /tmp/eksctl /usr/local/bin && \
    \
    # Helm
    apt-get install helm && \
    \
    rm -rf /var/lib/apt/list/*

# RUN apt update && \
#     apt install -y sudo vim nano jq figlet wget curl ssh python3 software-properties-common git locales-all libffi6 libffi-dev libssl-dev && \
#     apt install -y ca-certificates openssh-client wget curl iptables supervisor && \
#     add-apt-repository universe && \
#     apt update && \
#     apt install -y python3-pip



# Docker installation
RUN set -eux; \
	if ! wget -O docker.tgz "https://download.docker.com/linux/static/${DOCKER_CHANNEL}/${DOCKER_ARCH}/docker-${DOCKER_VERSION}.tgz"; then \
		echo >&2 "error: failed to download 'docker-${DOCKER_VERSION}' from '${DOCKER_CHANNEL}' for '${DOCKER_ARCH}'"; \
		exit 1; \
	fi; \
	\
	tar --extract \
		--file docker.tgz \
		--strip-components 1 \
		--directory /usr/local/bin/ \
	; \
	rm docker.tgz; \
	\
    echo "docker:x:1000:" >> /etc/group \
    \
    curl -L "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose && \
	chmod +x /usr/local/bin/docker-compose && \
    \
	dockerd --version; \
	docker --version

COPY modprobe startup.sh /usr/local/bin/
COPY supervisor/ /etc/supervisor/conf.d/
COPY logger.sh /opt/bash-utils/logger.sh

RUN chmod +x /usr/local/bin/startup.sh /usr/local/bin/modprobe
VOLUME /var/lib/docker


# No sudo prompts for us
RUN echo "${user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/custom-users && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    figlet "Multi Cloud Shell" > /etc/motd


FROM base AS tools

# user context
ARG user=mcs
USER ${user}
WORKDIR /home/${user}

COPY saveenv-az.sh .
COPY saveenv-aws.sh .
COPY saveenv-gcp.sh .

RUN \
    # Google
    pip3 install requests google-auth --user && \
    \
    # AWS
    pip3 install awscli boto boto3 --user && \
    echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc

FROM tools

# user context
ARG user=mcs
USER ${user}
WORKDIR /home/${user}

RUN tar cpzf /tmp/home.tgz /home/${user} && \
    echo "cat /etc/motd" >> .bashrc

WORKDIR /home/${user}

#ENTRYPOINT ["/bin/bash"]
#ENTRYPOINT ["startup.sh"]
CMD ["/usr/bin/sudo", "/usr/local/bin/startup.sh"]
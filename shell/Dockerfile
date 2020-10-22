FROM ubuntu:18.04 AS base

# root context
ARG VERSION=0.1
ARG user=mcs
ARG group=mcs
ARG uid
ARG gid

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

ENTRYPOINT ["/bin/bash"]

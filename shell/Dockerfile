FROM ubuntu:18.04 AS base

# root context
ARG VERSION=0.1
ARG user=mcs
ARG group=mcs
ARG uid
ARG gid

LABEL Description="This is the Multi Cloud Shell"

RUN ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime && echo ${TZ} > /etc/timezone && \
    addgroup -gid ${gid} ${group} || true && \
    useradd -m -s /bin/bash -d /home/${user} -u ${uid} -g ${gid} ${user}

COPY ["templates/.bash_aliases", "templates/.bashrc", "/home/${user}/"]

RUN chown ${user}.${gid} /home/${user}/.bash_aliases /home/${user}/.bashrc

COPY templates/add-apt-repository /usr/bin

RUN \
    # Enable Universe Repo
    apt update && \
    apt install -y python3 python3-pip software-properties-common curl apt-utils && \
    add-apt-repository universe && \
    \
    # Add Google Repo
    export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | \
        tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
        apt-key add - && \
    \
    # Add Azure Repos
    curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
        gpg --dearmor | \
        tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null && \
    export AZ_REPO=$(lsb_release -cs) && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
        tee /etc/apt/sources.list.d/azure-cli.list && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/microsoft-ubuntu-$(lsb_release -cs)-prod $(lsb_release -cs) main" | \
        tee /etc/apt/sources.list.d/dotnetdev.list && \
    \
    # Add Helm Repo
    curl https://baltocdn.com/helm/signing.asc | \
        apt-key add - && \
    apt-get install apt-transport-https --yes && \
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" | \
        tee /etc/apt/sources.list.d/helm-stable-debian.list && \
    \
    # Install Packages
    apt update && \
    apt install -y sudo vim nano jq figlet wget ssh git locales-all zip libffi6 libffi-dev \
        libssl-dev ca-certificates apt-transport-https lsb-release gnupg \
        iputils-ping net-tools dnsutils screen less groff bash-completion && \
    \
    # No sudo prompts for us
    echo "${user} ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/custom-users && \
    echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config && \
    figlet "Multi Cloud Shell" > /etc/motd && \
    \
    # Cleanup
    rm -rf /var/lib/apt/list/*

FROM base AS tools
ARG user=mcs
# root context
RUN \
    # AWS
    curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip && \
    unzip awscliv2.zip && \
    aws/install && \
    rm -rf awscliv2.zip \
        aws \
        /usr/local/aws-cli/v2/*/dist/aws_completer \
        /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index \
        /usr/local/aws-cli/v2/*/dist/awscli/examples && \
    \
    # Azure
    apt install -y azure-cli azure-functions-core-tools-3 && \
    curl --silent --location https://aka.ms/downloadazcopy-v10-linux | tar xz -C /tmp && \
    mv /tmp/azcopy_linux_amd64_10.11.0/azcopy /usr/bin && \
    rm -rf /tmp/azcopy_linux_amd64_10.11.0 && \
    chmod 755 /usr/bin/azcopy && \
    \
    # Google
    apt install -y google-cloud-sdk && \
    \
    # Kubectl
    apt install -y kubectl && \
    \
    # Eksctl
    curl --silent \
        --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | \
        tar xz -C /tmp && \
    mv -v /tmp/eksctl /usr/local/bin && \
    \
    # Helm
    apt install -y helm && \
    \
    # Stern
    curl --silent \
        --location https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64 -o stern && \
    chmod +x stern && \
    mv stern /usr/local/bin/stern && \
    \
    # Kubebox
    curl -Lo kubebox https://github.com/astefanutti/kubebox/releases/download/v0.9.0/kubebox-linux && \
    chmod +x kubebox && \
    mv kubebox /usr/local/bin/kubebox && \
    \
    sudo systemctl enable ssh && \
    \
    # Cleanup
    rm -rf /var/lib/apt/list/*

# user context
USER ${user}
WORKDIR /home/${user}

RUN \
    # Google
    pip3 install requests google-auth --user && \
    \
    # AWS
    pip3 install boto boto3 --user && \
    echo 'export PATH=~/.local/bin:$PATH' >> ~/.bashrc && \
    \
    # Krew
    curl -fsSL "https://github.com/kubernetes-sigs/krew/releases/latest/download/krew.tar.gz" -o ./krew.tar.gz && \
    tar zxvf ./krew.tar.gz && \
    KREW=./krew-"$(uname | tr '[:upper:]' '[:lower:]')_$(uname -m | sed -e 's/x86_64/amd64/' -e 's/arm.*$/arm/')" && \
    "$KREW" install krew && \
    rm -f ./krew.tar.gz ./krew-* && \
    echo 'export PATH=~/.krew/bin:$PATH' >> ~/.bashrc

FROM tools
# user context
ARG user=mcs
USER ${user}
WORKDIR /home/${user}

RUN tar cpzf /tmp/home.tgz /home/${user} && \
    echo "cat /etc/motd" >> .bashrc

EXPOSE 22

ENTRYPOINT ["/bin/bash"]

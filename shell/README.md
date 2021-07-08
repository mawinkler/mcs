# Multi Cloud Shell

- [Multi Cloud Shell](#multi-cloud-shell)
  - [Prerequisites](#prerequisites)
  - [Getting Started](#getting-started)
  - [How to use](#how-to-use)
  - [Tips & Tricks](#tips--tricks)
    - [Persistence](#persistence)
    - [Environment](#environment)
    - [Aliases](#aliases)

> **STILL WORK IN PROGRESS**

This repository provides a container image providing a multi cloud shell for AWS, Google and Azure. The core components of that image are:

- `gcloud` cli for Google
- `aws` cli for AWS
- `az` cli for Azure
- plus all additional tools and command line interfaces to manage kubernetes clusters

## Prerequisites

Docker & Docker-Compose

Tested with

- Linux,
- MacOS X and
- AWS

## Getting Started

<details>
<summary>Linux</summary>

Requirements for Docker & Docker-Compose

```sh
curl -fsSL get.docker.com -o get-docker.sh && sudo sh get-docker.sh
sudo usermod -aG docker `whoami` && sudo service docker start
sudo curl -L https://github.com/docker/compose/releases/download/1.24.0/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose && sudo chmod +x /usr/local/bin/docker-compose
```

</summary>
</details>

<details>
<summary>MacOS X</summary>


Requirements Docker for Desktop

<https://download.docker.com/mac/stable/Docker.dmg>

</summary>
</details>

<details>
<summary>AWS</summary>

Cloud9 requires a VPC with a public subnet available. If you don't have that within the desired region you need to create it before creating the Cloud9 instance, otherwise continue with the Cloud9 configuration.

- Create a VPC
  - Name tag: cloud9-vpc
  - IPv4 CIDR block: 10.0.0.0/16
  - IPv6 CIDR block: No
  - Tenancy: Default
- Create a Subnet
  - Name tag: cloud9-subnet
  - VPC: cloud9-vpc
  - Availability Zone: No preference
  - IPv4 CIDR block: 10.0.1.0/24
- Create an Internet Gateway
  - Name tag: cloud9-igw
- Attach Internet Gateway to VPC
  - VPC: cloud9-vpc
- Modify Route Table --> Routes --> Edit routes --> Add route
  - Destination 0.0.0.0/0
  - Target: cloud9-igw

Cloud9 Configuration:

- Name: \<whatever-you-like\>
- Instance type: >= t3.medium
- Platform: Ubuntu Server 18.04-LTS

From within the Cloud9 shell to a

```sh
sudo apt install -y docker-compose
```

Now clone the devops-training

```sh
git clone https://github.com/mawinkler/mcs.git
cd devops-training
```

</summary>
</details>

<details>
<summary>Windows</summary>

NOT SUPPORTED, FULLSTOP.

</summary>
</details>

## How to use

> **Note:** If you are using a Mac and iCloud Drive, you should move the shell folder to a location *not* within the scope if iCloud Drive. This is not mandatory but recommended.

Build and run it:

```shell
cd shell
```

If using AWS Cloud9 as the base, you likely need to increase the disk size of the Cloud9 instance depending on the type you chose above. Execute:

```sh
./resize.sh
```

Now build and start

```sh
./build.sh
./start.sh
```

<details>
<summary>Setup AWS</summary>

Authenticate to AWS via

```sh
aws configure
```

```sh
AWS Access Key ID [****************....]: <KEY>
AWS Secret Access Key [****************....]: <SECRET>
Default region name [eu-central-1]: 
Default output format [None]: json
```

```sh
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --output text --query Account)
export AWS_REGION=$(cat ~/.aws/config | sed -n 's/^region\s=\s\(.*\)/\1/p')
```

</summary>
</details>

<details>
<summary>Setup Azure</summary>

Authenticate to Azure via

```sh
az login
```

and follow the process.

</summary>
</details>

<details>
<summary>Setup Google</summary>

Authenticate to GCP via

```sh
gcloud auth login
```

and follow the process.

</summary>
</details>

## Tips & Tricks

### Persistence

Persistence is provided by a mapped working directory on your docker host. That means, you can easily destroy and rebuild the image whenever needed. If you want to move your setup, simply tar / zip your local repo directory including the workdir.

MCS is designed to allow file read / write not only from within the container, but also from your host running the shell. So, simply use your local editor of choice and modify any file within the workdir as you like. All changes will be immedeately available within the mcs.

### Environment

To save and restore your environment variables run

```sh
# Dump environment to disk
env_save
```

or

```sh
# Restore environment from disk
env_restore`
```

### Aliases

There are hundreds of aliases set for your convenience. To point out some of the most used:

*Kubernetes*

- `kchns <NAMESPACE>` change your working context to a specific namespace, avoiding the requirement to allways do `kubectl -n <NAMESPACE>`.
- `kgpo` list all pods in the current namespace.
- `kgsvc` list all pods in the current namespace.
- `kshell` creates a shell running in a pod in the actual workspace. You're root in that shell.
- `keti <POD NAME>` beams you to a shell in the named pod.
- `stern . -t -s10m` will give you realtime logs of all pods in the current namespace including a history of 10 mins. Very handy when debugging deployments.

*Shell*

- `scr` creates or reattaches mcs to screened shells, making it possible to switch in between multiple shells within mcs.
  - Ctrl+a c Create a new window (with shell).
  - Ctrl+a " List all windows.
  - Ctrl+a 0 Switch to window 0 (by number).
  - Ctrl+a A Rename the current window.
  - Ctrl+a S Split current region horizontally into two regions.
  - Ctrl+a | Split current region vertically into two regions.
  - Ctrl+a tab Switch the input focus to the next region.
  - Ctrl+a Ctrl+a Toggle between the current and previous windows
  - Ctrl+a Q Close all regions but the current one.
  - Ctrl+a X Close the current region.
  - Ctrl+a d You can detach from the screen session. If you run `scr` again, you will reattach to the screen session.
- `.. <LEVEL>` traverses down multiple `LEVEL`s from the current path.

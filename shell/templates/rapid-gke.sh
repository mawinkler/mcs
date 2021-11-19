#!/bin/bash

# Exports
export ZONE=europe-west2-b
export CLUSTER=playground

# Setup a project
echo "Create project..."
export PROJECT_ID=playground-$(openssl rand -hex 4)
gcloud projects create ${PROJECT_ID} --name devops-training
gcloud -q config set project ${PROJECT_ID}
gcloud -q config set compute/zone $ZONE

# Enable billing
echo "Enable billing..."
export BILLING_ACCOUNT=$(gcloud alpha billing accounts list | sed -n 's/\([0-9A-F]\{1,6\}-[0-9A-F]\{1,6\}-[0-9A-F]\{1,6\}\)\s.*/\1/p')
gcloud alpha billing projects link ${PROJECT_ID} \
  --billing-account ${BILLING_ACCOUNT}

# Enable APIs
echo "Enable APIs..."
gcloud services enable \
    container.googleapis.com \
    containerregistry.googleapis.com \
    cloudbuild.googleapis.com \
    sourcerepo.googleapis.com \
    compute.googleapis.com \
    cloudresourcemanager.googleapis.com

# Create Cluster
echo "Creating cluster... (4CPU/16GB per node)"
gcloud container clusters create ${CLUSTER} \
    --project=${PROJECT_ID} \
    --zone=${ZONE} \
    --release-channel=rapid \
    --machine-type=e2-standard-4 \
    --scopes "https://www.googleapis.com/auth/projecthosting,storage-rw"

echo "Creating rapid-gke-down.sh script"
cat <<EOF >rapid-gke-down.sh
#!/bin/bash
gcloud -q container clusters delete ${CLUSTER}
gcloud -q projects delete ${PROJECT_ID}
EOF
chmod +x rapid-gke-down.sh
echo "Run rapid-gke-down.sh to tear down everything"

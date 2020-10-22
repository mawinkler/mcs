#!/bin/bash
echo "\
export PROJECT_ID=${PROJECT_ID}
export ZONE=${ZONE}
export CLUSTER=${CLUSTER}
export PROJECT_NUMBER=${PROJECT_NUMBER}
export GCR_SERVICE_ACCOUNT=${GCR_SERVICE_ACCOUNT}
export DSSC_NAMESPACE=${DSSC_NAMESPACE}
export DSSC_USERNAME=${DSSC_USERNAME}
export DSSC_PASSWORD=${DSSC_PASSWORD}
export DSSC_REGUSER=${DSSC_REGUSER}
export DSSC_REGPASSWORD=${DSSC_REGPASSWORD}
export DSSC_AC=${DSSC_AC}
export DSSC_HOST=${DSSC_HOST}
export TREND_AP_KEY=${TREND_AP_KEY}
export TREND_AP_SECRET=${TREND_AP_SECRET}
export APP_NAME=${APP_NAME}
export GITHUB_USERNAME=${GITHUB_USERNAME}
export IMAGE_NAME=${IMAGE_NAME}
export IMAGE_TAG=${IMAGE_TAG}
" > ~/.gcp-lab.sh
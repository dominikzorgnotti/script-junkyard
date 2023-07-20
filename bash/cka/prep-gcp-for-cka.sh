# Steps to prep a brand new GCP project for the CKA prep
# Use the GCP shell with gcloud for this

# One time tasks

## Create a storage bucket for the startup script
gcloud storage buckets create gs://bucket-cka-prep-01

## Enable versioning on the bucket
gcloud storage buckets update gs://bucket-cka-prep-01  --versioning

## Copy startup-script to the storage bucket
wget https://raw.githubusercontent.com/dominikzorgnotti/script-junkyard/main/bash/cka-k8s-basic-setup-ubuntu2004.sh
gcloud storage cp cka-k8s-basic-setup-ubuntu2004.sh gs://bucket-cka-prep-01/cka-k8s-basic-setup-ubuntu2004.sh

## Enable GCP compute APIs
gcloud services enable

## Create an instance template
gcloud compute instance-templates create it-cka-prep-v01 --machine-type=t2d-standard-1 --metadata=startup-script-url=gs://bucket-cka-prep-01/cka-k8s-basic-setup-ubuntu2004.sh --scopes=https://www.googleapis.com/auth/cloud-platform --tags=k8s --create-disk=auto-delete=yes,boot=yes,device-name=it-cka-prep-v01,image=projects/ubuntu-os-cloud/global/images/ubuntu-2004-focal-v20230715,mode=rw,size=40,type=pd-balanced


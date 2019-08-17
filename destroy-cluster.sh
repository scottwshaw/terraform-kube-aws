#!/bin/bash
set -e
set x
export AWS_PROFILE=kcastudy-user-2
terraform destroy -input=false -auto-approve -var-file=terraform.tfvars


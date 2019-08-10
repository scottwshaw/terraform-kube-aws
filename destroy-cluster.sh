#!/bin/bash
set -e
set x
source ./aws-keys.sh
terraform destroy -input=false -auto-approve -var-file=terraform.tfvars


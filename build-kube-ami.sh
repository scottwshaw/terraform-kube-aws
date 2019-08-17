#!/bin/bash
set -e
set x
export AWS_PROFILE=kcastudy-user-2

packer build kube-ami-template.json

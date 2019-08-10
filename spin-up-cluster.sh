#!/bin/bash
set -e
set x
source aws-keys.sh
terraform apply -auto-approve -var-file=terraform.tfvars
WORKER_DNS_NAMES=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Worker*'   --output text --query 'Reservations[*].Instances[*].PublicDnsName')
MASTER_DNS_NAME=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Master'   --output text --query 'Reservations[*].Instances[*].PublicDnsName')
MASTER_PRIVATE_IP=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Master'   --output text --query 'Reservations[*].Instances[*].PrivateIpAddress')
JOIN_TOKEN=$(ssh -o CheckHostIP=no -i kcastudy01.pem ubuntu@$MASTER_DNS_NAME kubeadm token generate)
JOIN_COMMAND=$(ssh -i kcastudy01.pem -o CheckHostIP=no ubuntu@$MASTER_DNS_NAME kubeadm token create $JOIN_TOKEN --print-join-command)
for name in $WORKER_DNS_NAMES
do
    ssh -i kcastudy01.pem -o CheckHostIP=no ubuntu@$name $JOIN_COMMAND
done
echo "kube master name is " $MASTER_DNS_NAME


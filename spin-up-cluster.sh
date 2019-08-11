#!/bin/bash
set -e
set x
source aws-keys.sh
terraform apply -auto-approve -var-file=terraform.tfvars
export WORKER_IP=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Worker*'   --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
export MASTER_IP=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Master'   --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "workers are " $(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Worker*'   --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
echo "master is " $(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Master'   --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
ssh-keyscan -H $MASTER_IP >> ~/.ssh/known_hosts
echo "getting join token"
export JOIN_TOKEN=$(ssh -v -i kcastudy01.pem ubuntu@$MASTER_IP kubeadm token generate)
echo "generating join command"
export JOIN_COMMAND=$(ssh -i kcastudy01.pem ubuntu@$MASTER_IP kubeadm token create $JOIN_TOKEN --print-join-command)
echo "joining cluster"
for ip in $WORKER_IP
do
    echo "scanning for key, ip=" $ip
    ssh-keyscan -H $ip >> ~/.ssh/known_hosts
    echo "joining"
    ssh -i kcastudy01.pem ubuntu@$ip sudo $JOIN_COMMAND
done
echo "kube master IP is " $MASTER_IP


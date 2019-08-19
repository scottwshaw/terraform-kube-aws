#!/bin/bash
set -e
set x
export AWS_PROFILE=kcastudy-user-2
export AWS_KEY_FILE=kcastudy02.pem

terraform apply -auto-approve -var-file=terraform.tfvars
export WORKER_IP=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Worker*'   --output text --query 'Reservations[*].Instances[*].PublicIpAddress')
export MASTER_IP=$(aws ec2 describe-instances --filters 'Name=tag:Name,Values=Kube Master'   --output text --query 'Reservations[*].Instances[*].PublicIpAddress')

echo "scanning ssh keys"
ssh-keyscan -H $MASTER_IP >> ~/.ssh/known_hosts
echo "initialising kube master"
scp -i $AWS_KEY_FILE init-kube-master.sh ubuntu@$MASTER_IP:/tmp/ikm.sh
ssh -i $AWS_KEY_FILE ubuntu@$MASTER_IP chmod a+x /tmp/ikm.sh
ssh -i $AWS_KEY_FILE ubuntu@$MASTER_IP /tmp/ikm.sh $MASTER_IP
echo "getting join token"
export JOIN_TOKEN=$(ssh -v -i $AWS_KEY_FILE ubuntu@$MASTER_IP kubeadm token generate)
echo "generating join command"
export JOIN_COMMAND=$(ssh -i $AWS_KEY_FILE ubuntu@$MASTER_IP kubeadm token create $JOIN_TOKEN --print-join-command)
echo "joining cluster"
for ip in $WORKER_IP
do
    echo "scanning for key, ip=" $ip
    ssh-keyscan -H $ip >> ~/.ssh/known_hosts
    echo "joining"
    ssh -i $AWS_KEY_FILE ubuntu@$ip sudo $JOIN_COMMAND
done
echo "kube master IP is " $MASTER_IP
echo "workers are " $WORKER_IP


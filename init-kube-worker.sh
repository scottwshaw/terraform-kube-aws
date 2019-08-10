#!/bin/bash
MASTER_NAME=$1
set -e
set x
### On worker nodes execute this:
echo "master is on " $1
sudo kubeadm join $MASTER_NAME:6443 --token 2x2uui.dsglv32d5v1x6y5o --discovery-token-ca-cert-hash sha256:bf7232ddb2dee358a65a250c7fe125564d51b80f31b6239d7357d66d79d2e71b
### End of worker


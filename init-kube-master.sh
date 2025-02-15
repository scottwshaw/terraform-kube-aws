#!/bin/bash
set -e
export PUBLIC_IP=$1
set x
echo "sleeping for 10 seconds to let everything settle"
sleep 10
echo "net.bridge.bridge-nf-call-iptables=1" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
sudo kubeadm init --pod-network-cidr=10.244.0.0/16 --apiserver-cert-extra-sans=$PUBLIC_IP
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/bc79dd1505b0c8681ece4de4c0d86c5cd2643275/Documentation/kube-flannel.yml


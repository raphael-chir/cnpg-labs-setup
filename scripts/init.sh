#!/bin/bash -xe
# EC2 initialization setup (root user)

apt update -y
apt-get install -y \
    ttyd tmux \
    net-tools iproute2 iputils-ping dnsutils curl wget \
    htop tcpdump traceroute nmap openssh-server vim nano tmux \
    unzip lsof whois bash-completion ca-certificates gnupg apt-transport-https gpg jq

# Docker installation
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu noble stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
usermod -aG docker ubuntu

# Kind installation
echo "➡ Kind installation"
curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.27.0/kind-linux-amd64
chmod +x /usr/local/bin/kind

# Helm installation
echo "➡ Helm installation..."
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor -o /usr/share/keyrings/helm.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | tee /etc/apt/sources.list.d/helm-stable-debian.list
apt-get update
apt-get install -y helm

# Kubectl installation
echo "➡ Kubectl installation ..."
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" | tee /etc/apt/sources.list.d/kubernetes.list
chmod 644 /etc/apt/sources.list.d/kubernetes.list
apt-get update
apt-get install -y kubectl

# Kubectl autocompletion
echo 'source <(kubectl completion bash)' | tee -a /root/.bashrc /home/ubuntu/.bashrc > /dev/null

# Lab resources
git clone https://github.com/raphael-chir/cnpg-ha.git /home/ubuntu/cnpg-ha
chown -R ubuntu:ubuntu /home/ubuntu/cnpg-ha

# Kind cluster creation
kind create cluster --verbosity 9 --config /home/ubuntu/cnpg-ha/conf/kind-cluster-config.yaml

# kube config for vagrant user
mkdir -p /home/ubuntu/.kube
cp /.kube/config /home/ubuntu/.kube/config
chown ubuntu:ubuntu /home/ubuntu/.kube/config

# Minio Setup for backup
docker run -p 9000:9000 -p 9001:9001 \
           -e MINIO_ROOT_USER=admin \
           -e MINIO_ROOT_PASSWORD=password \
           -d \
           --network kind\
           --name minio \
           minio/minio server /data \
           --console-address ":9001"

# MinIO secrets
kubectl create secret generic minio-creds \
  --from-literal=MINIO_ACCESS_KEY=admin \
  --from-literal=MINIO_SECRET_KEY=password

# Prometheus / Grafana
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

helm upgrade --install --namespace monitoring --create-namespace \
  -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/main/docs/src/samples/monitoring/kube-stack-config.yaml \
  prometheus-community \
  prometheus-community/kube-prometheus-stack

# ttyd and tmux setup
echo 'Start ttyd and tmux setup ...'

cat <<EOF > /home/ubuntu/.tmux.conf
unbind C-b
set -g prefix C-Space
bind-key C-Space send-prefix
bind C-Right split-window -hc "#{pane_current_path}"
bind C-Down split-window -vc "#{pane_current_path}"
set-option -g history-limit 50000
set -g mouse on
unbind -n MouseDown3Pane
EOF

chown ubuntu:ubuntu /home/ubuntu/.tmux.conf
setcap 'cap_net_bind_service=+ep' /usr/bin/ttyd
sudo -u ubuntu tmux new-session -d -s ttyd-session -c /home/ubuntu
sudo -u ubuntu bash -c 'nohup /usr/bin/ttyd -p 80 -W tmux attach -t ttyd-session > /home/ubuntu/ttyd.log 2>&1 &'

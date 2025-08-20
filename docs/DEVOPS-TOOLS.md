# 🛠️ DevOps Tools Installation Guide

**Essential tools for cloud engineers and DevOps professionals**

This guide covers installing and configuring professional DevOps tools on your Arch Hyprland Bare system. Perfect for those who "live in the terminal" and work with cloud infrastructure.

## 📋 Table of Contents

- [Container Technologies](#container-technologies)
- [Kubernetes Ecosystem](#kubernetes-ecosystem)
- [Cloud Provider CLIs](#cloud-provider-clis)
- [Infrastructure as Code](#infrastructure-as-code)
- [CI/CD Tools](#cicd-tools)
- [Monitoring & Observability](#monitoring--observability)
- [Security Tools](#security-tools)
- [Programming Languages](#programming-languages)
- [Database Tools](#database-tools)
- [Network Tools](#network-tools)
- [Terminal Enhancements](#terminal-enhancements)

## 🐳 Container Technologies

### Docker
```bash
# Install Docker
sudo pacman -S docker docker-compose docker-buildx

# Enable and start service
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker version
docker run hello-world

# Useful aliases
echo 'alias d="docker"' >> ~/.bashrc
echo 'alias dc="docker-compose"' >> ~/.bashrc
echo 'alias dps="docker ps"' >> ~/.bashrc
echo 'alias di="docker images"' >> ~/.bashrc
```

### Podman (Docker Alternative)
```bash
# Install Podman
sudo pacman -S podman podman-compose

# Configure rootless containers
echo 'kernel.unprivileged_userns_clone=1' | sudo tee /etc/sysctl.d/99-rootless.conf
sudo sysctl --system

# Set up registries
sudo mkdir -p /etc/containers
echo 'unqualified-search-registries = ["docker.io", "quay.io"]' | sudo tee /etc/containers/registries.conf

# Aliases for Docker compatibility
echo 'alias docker="podman"' >> ~/.bashrc
echo 'alias docker-compose="podman-compose"' >> ~/.bashrc
```

### Container Security
```bash
# Trivy (vulnerability scanner)
yay -S trivy

# Dive (image layer analyzer)
yay -S dive

# Hadolint (Dockerfile linter)
yay -S hadolint-bin

# Usage examples
trivy image nginx:latest
dive nginx:latest
hadolint Dockerfile
```

## ☸️ Kubernetes Ecosystem

### Core Tools
```bash
# kubectl
sudo pacman -S kubectl

# Helm (package manager)
sudo pacman -S helm

# kubectx/kubens (context switching)
yay -S kubectx

# k9s (TUI cluster manager)
yay -S k9s

# stern (log tailing)
yay -S stern

# kubectl aliases
echo 'alias k="kubectl"' >> ~/.bashrc
echo 'alias kgp="kubectl get pods"' >> ~/.bashrc
echo 'alias kgs="kubectl get services"' >> ~/.bashrc
echo 'alias kgd="kubectl get deployments"' >> ~/.bashrc
echo 'alias kdp="kubectl describe pod"' >> ~/.bashrc
echo 'alias kaf="kubectl apply -f"' >> ~/.bashrc
echo 'alias kdel="kubectl delete"' >> ~/.bashrc
```

### Local Kubernetes
```bash
# Minikube
yay -S minikube

# Kind (Kubernetes in Docker)
yay -S kind-bin

# K3s (lightweight Kubernetes)
curl -sfL https://get.k3s.io | sh -

# Start minikube cluster
minikube start --driver=docker
minikube addons enable dashboard
minikube addons enable ingress
```

### Advanced Kubernetes Tools
```bash
# Kustomize (configuration management)
sudo pacman -S kustomize

# Skaffold (development workflow)
yay -S skaffold

# Telepresence (local development with remote cluster)
yay -S telepresence

# Flux (GitOps)
yay -S flux-bin

# ArgoCD CLI
yay -S argocd-bin

# Istio service mesh
curl -L https://istio.io/downloadIstio | sh -
sudo mv istio-*/bin/istioctl /usr/local/bin/
```

## ☁️ Cloud Provider CLIs

### AWS
```bash
# AWS CLI v2
sudo pacman -S aws-cli-v2

# AWS Session Manager plugin
yay -S session-manager-plugin

# AWS SAM CLI
yay -S aws-sam-cli

# Configure AWS
aws configure
# Enter: Access Key, Secret Key, Region (e.g., us-east-1), Output format (json)

# Useful aliases
echo 'alias awsp="aws --profile"' >> ~/.bashrc
echo 'alias s3ls="aws s3 ls"' >> ~/.bashrc
echo 'alias ec2ls="aws ec2 describe-instances --query \"Reservations[].Instances[].[InstanceId,State.Name,InstanceType,PublicIpAddress,Tags[?Key==\\'Name\\'].Value|[0]]\" --output table"' >> ~/.bashrc
```

### Azure
```bash
# Azure CLI
yay -S azure-cli

# Login and configure
az login
az account set --subscription "Your-Subscription-Name"

# Useful aliases
echo 'alias azls="az resource list --output table"' >> ~/.bashrc
echo 'alias azvms="az vm list --output table"' >> ~/.bashrc
```

### Google Cloud Platform
```bash
# Google Cloud SDK
yay -S google-cloud-cli

# Additional components
gcloud components install gke-gcloud-auth-plugin
gcloud components install kubectl

# Initialize and authenticate
gcloud init
gcloud auth login

# Useful aliases
echo 'alias gcls="gcloud compute instances list"' >> ~/.bashrc
echo 'alias gks="gcloud container clusters get-credentials"' >> ~/.bashrc
```

### DigitalOcean
```bash
# doctl CLI
yay -S doctl

# Configure
doctl auth init

# Aliases
echo 'alias dols="doctl compute droplet list"' >> ~/.bashrc
echo 'alias dok8s="doctl kubernetes cluster kubeconfig save"' >> ~/.bashrc
```

## 🏗️ Infrastructure as Code

### Terraform
```bash
# Install Terraform
yay -S terraform

# TFLint (Terraform linter)
yay -S tflint

# Terragrunt (Terraform wrapper)
yay -S terragrunt

# Terraform docs generator
yay -S terraform-docs

# Useful aliases
echo 'alias tf="terraform"' >> ~/.bashrc
echo 'alias tfi="terraform init"' >> ~/.bashrc
echo 'alias tfp="terraform plan"' >> ~/.bashrc
echo 'alias tfa="terraform apply"' >> ~/.bashrc
echo 'alias tfd="terraform destroy"' >> ~/.bashrc
echo 'alias tfo="terraform output"' >> ~/.bashrc

# Setup terraform completion
terraform -install-autocomplete
```

### Ansible
```bash
# Install Ansible
sudo pacman -S ansible

# Ansible Lint
sudo pacman -S ansible-lint

# Useful tools
yay -S ansible-vault

# Create ansible.cfg
cat > ~/.ansible.cfg << EOF
[defaults]
host_key_checking = False
inventory = ./inventory
private_key_file = ~/.ssh/id_rsa
remote_user = root

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
EOF
```

### Pulumi
```bash
# Pulumi (Infrastructure as Code with real languages)
yay -S pulumi

# Login to Pulumi service or self-hosted
pulumi login

# Useful aliases
echo 'alias pu="pulumi"' >> ~/.bashrc
echo 'alias pup="pulumi up"' >> ~/.bashrc
echo 'alias pud="pulumi destroy"' >> ~/.bashrc
```

### Other IaC Tools
```bash
# Packer (image building)
yay -S packer

# Vagrant (development environments)
sudo pacman -S vagrant

# CloudFormation tools
yay -S cfn-lint
yay -S rain  # CloudFormation deployment tool
```

## 🔄 CI/CD Tools

### Jenkins
```bash
# Jenkins (if running locally)
yay -S jenkins

# Jenkins CLI
wget https://your-jenkins-url/jnlpJars/jenkins-cli.jar
```

### GitHub CLI
```bash
# GitHub CLI
sudo pacman -S github-cli

# Authenticate
gh auth login

# Useful commands
gh repo list
gh pr list
gh issue list
gh workflow list
```

### GitLab CLI
```bash
# GitLab CLI
yay -S glab

# Configure
glab auth login

# Usage
glab mr list
glab pipeline list
```

### Other CI/CD Tools
```bash
# Act (run GitHub Actions locally)
yay -S act

# CircleCI CLI
yay -S circleci-cli

# Tekton CLI
yay -S tektoncd-cli
```

## 📊 Monitoring & Observability

### Prometheus Ecosystem
```bash
# Prometheus
yay -S prometheus

# Grafana
yay -S grafana

# Alertmanager
yay -S alertmanager

# Node Exporter
yay -S prometheus-node-exporter

# Start services
sudo systemctl enable --now prometheus
sudo systemctl enable --now grafana
```

### Logging Stack
```bash
# Elasticsearch, Logstash, Kibana
yay -S elasticsearch
yay -S logstash
yay -S kibana

# Fluentd
yay -S fluentd

# Vector (high-performance log router)
yay -S vector
```

### Application Performance Monitoring
```bash
# Jaeger (distributed tracing)
yay -S jaeger

# OpenTelemetry CLI
yay -S otel-cli
```

### System Monitoring (Already have btop, adding more)
```bash
# Netdata (real-time monitoring)
sudo pacman -S netdata

# Prometheus exporters
yay -S prometheus-blackbox-exporter
yay -S prometheus-postgres-exporter

# Start netdata
sudo systemctl enable --now netdata
```

## 🔐 Security Tools

### Secrets Management
```bash
# HashiCorp Vault
yay -S vault

# SOPS (encrypted secrets)
yay -S sops

# Age (encryption tool)
yay -S age

# Example: encrypt with SOPS
sops --encrypt --age $(age-keygen -y key.txt) secrets.yaml > secrets.enc.yaml
```

### Security Scanning
```bash
# Checkov (infrastructure security)
yay -S checkov

# TruffleHog (secret scanner)
yay -S trufflehog

# Grype (vulnerability scanner)
yay -S grype

# Syft (SBOM generator)
yay -S syft

# Usage examples
checkov -f main.tf
trufflehog git https://github.com/example/repo
grype nginx:latest
syft nginx:latest
```

### Network Security
```bash
# Nmap (network scanner)
sudo pacman -S nmap

# Wireshark (packet analyzer)
sudo pacman -S wireshark-qt

# OpenVPN
sudo pacman -S openvpn

# WireGuard
sudo pacman -S wireguard-tools
```

## 💻 Programming Languages

### Go
```bash
# Go language
sudo pacman -S go

# Go tools
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/air-verse/air@latest  # Live reload
go install github.com/goreleaser/goreleaser@latest

# Add Go bin to PATH
echo 'export PATH=$PATH:$(go env GOPATH)/bin' >> ~/.bashrc
```

### Python
```bash
# Python is already installed, add tools
sudo pacman -S python-pip python-pipenv python-virtualenv

# Poetry (dependency management)
yay -S python-poetry

# Python tools
pip install --user black flake8 mypy pytest

# Virtual environment
echo 'alias venv="python -m venv"' >> ~/.bashrc
echo 'alias activate="source venv/bin/activate"' >> ~/.bashrc
```

### Node.js
```bash
# Node.js and npm
sudo pacman -S nodejs npm

# Yarn
sudo pacman -S yarn

# NVM (Node Version Manager)
yay -S nvm

# Global packages
npm install -g typescript ts-node nodemon
npm install -g @aws-cdk/cli
npm install -g serverless
```

### Rust
```bash
# Rust
sudo pacman -S rustup

# Set up Rust
rustup default stable
rustup component add clippy rustfmt

# Cargo tools
cargo install cargo-watch
cargo install cargo-audit
cargo install cargo-outdated
```

### Java
```bash
# OpenJDK
sudo pacman -S jdk-openjdk

# Maven
sudo pacman -S maven

# Gradle
sudo pacman -S gradle

# SDKMAN for managing Java versions
curl -s "https://get.sdkman.io" | bash
```

## 🗄️ Database Tools

### Database Clients
```bash
# Universal database tool
yay -S dbeaver

# PostgreSQL client
sudo pacman -S postgresql-clients

# MySQL client
sudo pacman -S mysql-clients

# MongoDB client
yay -S mongodb-compass

# Redis client
sudo pacman -S redis
yay -S redis-desktop-manager
```

### Database CLIs
```bash
# pgcli (PostgreSQL CLI with autocomplete)
pip install --user pgcli

# mycli (MySQL CLI with autocomplete)
pip install --user mycli

# MongoDB shell
yay -S mongodb-shell

# Usage examples
pgcli postgresql://user:password@localhost/database
mycli -u username -p password database_name
```

## 🌐 Network Tools

### HTTP/API Tools
```bash
# HTTPie (user-friendly curl)
sudo pacman -S httpie

# Curl (already installed, but adding here)
# curl is already available

# Postman alternative
yay -S insomnia-bin

# gRPC tools
yay -S grpcurl
yay -S ghz  # gRPC load testing

# Usage examples
http GET httpbin.org/json
curl -X POST https://api.example.com/data
grpcurl -plaintext localhost:9090 list
```

### Network Diagnostics
```bash
# Network tools (most already available)
sudo pacman -S traceroute mtr bind-tools

# Speedtest
yay -S speedtest-cli

# Network bandwidth monitor
sudo pacman -S iftop nethogs

# Usage
mtr google.com
speedtest
sudo iftop
sudo nethogs
```

## 🚀 Terminal Enhancements

### Shell Improvements (Building on existing setup)
```bash
# starship prompt (modern prompt)
yay -S starship

# Add to bashrc
echo 'eval "$(starship init bash)"' >> ~/.bashrc

# zsh (alternative shell)
sudo pacman -S zsh zsh-completions
yay -S oh-my-zsh-git

# Fish shell (user-friendly)
sudo pacman -S fish
```

### Productivity Tools
```bash
# jq (JSON processor) - already have this
# yq (YAML processor)
yay -S yq

# fx (JSON viewer)
yay -S fx

# Miller (data processing)
yay -S miller

# Usage examples
cat data.json | jq '.items[]'
cat config.yaml | yq '.services'
cat data.json | fx
```

### File Management
```bash
# ranger (TUI file manager)
sudo pacman -S ranger

# nnn (fast file manager)
sudo pacman -S nnn

# lf (minimalist file manager)
yay -S lf

# Usage
ranger  # Navigate with hjkl
nnn     # Very fast navigation
lf      # Minimal interface
```

## 🔧 Configuration Examples

### Tmux DevOps Configuration
Add to your `~/.tmux.conf`:
```bash
# DevOps specific tmux bindings
bind-key K split-window -h 'kubectl get pods --watch'
bind-key D split-window -h 'docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
bind-key T split-window -h 'terraform plan'
bind-key A split-window -h 'ansible-playbook --check playbook.yml'

# Quick commands
bind-key C-k send-keys 'kubectl get pods' Enter
bind-key C-d send-keys 'docker ps' Enter
bind-key C-t send-keys 'terraform' Space
bind-key C-a send-keys 'ansible-playbook' Space
```

### Kubectl Configuration
```bash
# Create useful kubectl aliases
cat >> ~/.bashrc << 'EOF'
# Kubectl aliases
alias k='kubectl'
alias kaf='kubectl apply -f'
alias kdel='kubectl delete'
alias kget='kubectl get'
alias kdesc='kubectl describe'
alias klogs='kubectl logs'
alias kexec='kubectl exec -it'

# Kubernetes contexts
alias kctx='kubectx'
alias kns='kubens'

# Quick pod access
kpod() { kubectl exec -it $(kubectl get pods | grep $1 | awk '{print $1}' | head -1) -- /bin/bash; }
EOF
```

### Docker Configuration
```bash
# Docker aliases for productivity
cat >> ~/.bashrc << 'EOF'
# Docker aliases
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dpsa='docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias di='docker images --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'
alias dlog='docker logs -f'
alias dexec='docker exec -it'
alias dclean='docker system prune -a'

# Quick container access
dsh() { docker exec -it $1 /bin/bash; }
EOF
```

## 📚 Learning Resources

### Documentation & Cheat Sheets
```bash
# Install cheat (cheat sheets)
yay -S cheat

# Install tldr (simplified man pages)
sudo pacman -S tldr

# Update cheat sheets
cheat --update

# Usage examples
cheat docker
cheat kubectl
tldr curl
tldr ssh
```

### Online Resources
- **Kubernetes**: [kubernetes.io/docs](https://kubernetes.io/docs/)
- **Docker**: [docs.docker.com](https://docs.docker.com/)
- **Terraform**: [terraform.io/docs](https://terraform.io/docs/)
- **Ansible**: [docs.ansible.com](https://docs.ansible.com/)
- **AWS**: [docs.aws.amazon.com](https://docs.aws.amazon.com/)
- **Azure**: [docs.microsoft.com/azure](https://docs.microsoft.com/azure/)
- **GCP**: [cloud.google.com/docs](https://cloud.google.com/docs/)

## 🔄 Maintenance & Updates

### Keep Tools Updated
```bash
# Update all packages
yay -Syu

# Update specific tools
terraform version  # Check current version
yay -S terraform   # Update to latest

# Update cloud CLIs
aws --version
az version
gcloud version

# Update Kubernetes tools
kubectl version --client
helm version
```

### Backup Important Configurations
```bash
# Backup kubectl configs
cp -r ~/.kube ~/.kube.backup

# Backup cloud CLI configs
cp -r ~/.aws ~/.aws.backup
cp -r ~/.azure ~/.azure.backup
cp -r ~/.config/gcloud ~/.config/gcloud.backup

# Backup SSH keys
cp -r ~/.ssh ~/.ssh.backup

# Create a dotfiles backup
tar -czf devops-configs-$(date +%Y%m%d).tar.gz \
    ~/.kube ~/.aws ~/.azure ~/.config/gcloud ~/.ssh/config \
    ~/.tmux.conf ~/.bashrc ~/.gitconfig
```

### Performance Optimization
```bash
# Optimize shell startup time
echo 'export HISTSIZE=1000' >> ~/.bashrc
echo 'export HISTFILESIZE=2000' >> ~/.bashrc

# Enable completion caching
echo 'autoload -U compinit && compinit -C' >> ~/.zshrc  # if using zsh

# Docker optimization
echo '{"log-driver": "json-file", "log-opts": {"max-size": "10m", "max-file": "3"}}' | sudo tee /etc/docker/daemon.json
sudo systemctl restart docker
```

## 🛡️ Security Best Practices

### SSH Configuration
```bash
# Generate SSH keys for different purposes
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_work -C "work@example.com"
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_personal -C "personal@example.com"

# SSH config for different environments
cat > ~/.ssh/config << 'EOF'
# Work servers
Host work-*
    User devops
    IdentityFile ~/.ssh/id_ed25519_work
    IdentitiesOnly yes

# Personal servers
Host personal-*
    User admin
    IdentityFile ~/.ssh/id_ed25519_personal
    IdentitiesOnly yes

# AWS EC2 instances
Host *.amazonaws.com
    User ec2-user
    IdentityFile ~/.ssh/aws-key.pem
    IdentitiesOnly yes

# Global settings
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 10
    ForwardAgent no
    AddKeysToAgent yes
EOF
```

### Git Configuration for DevOps
```bash
# Configure Git for work
git config --global user.name "Your Name"
git config --global user.email "your.email@company.com"
git config --global init.defaultBranch main

# Useful Git aliases
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.cm commit
git config --global alias.pl pull
git config --global alias.ps push
git config --global alias.lg "log --oneline --graph --all"

# Sign commits (optional but recommended)
git config --global commit.gpgsign true
git config --global user.signingkey YOUR_GPG_KEY_ID
```

### Secrets Management
```bash
# Install and configure pass (password store)
sudo pacman -S pass

# Initialize password store
gpg --gen-key
pass init your-gpg-key-id

# Store secrets
pass insert aws/access-key
pass insert github/token
pass insert database/password

# Use in scripts
AWS_ACCESS_KEY=$(pass show aws/access-key)
```

## 🚀 Quick Setup Scripts

### One-liner Installations

```bash
# Essential DevOps stack
yay -S --noconfirm docker docker-compose kubectl helm terraform ansible aws-cli-v2 k9s

# Monitoring stack
yay -S --noconfirm prometheus grafana netdata

# Security tools
yay -S --noconfirm vault sops trivy

# Programming languages
sudo pacman -S --noconfirm go nodejs npm python-poetry rustup
```

### Environment Setup Script
Create `~/bin/setup-devops.sh`:
```bash
#!/bin/bash
# DevOps Environment Setup Script

set -e

echo "🚀 Setting up DevOps environment..."

# Create directories
mkdir -p ~/bin ~/projects/{terraform,ansible,k8s,docker}

# Install essential packages
yay -S --noconfirm docker kubectl helm terraform ansible

# Configure Docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Setup aliases
cat >> ~/.bashrc << 'EOF'
# DevOps aliases
alias k='kubectl'
alias tf='terraform'
alias d='docker'
alias dc='docker-compose'
EOF

# Create useful scripts
cat > ~/bin/k8s-context << 'EOF'
#!/bin/bash
kubectl config get-contexts
read -p "Enter context name: " context
kubectl config use-context $context
EOF

chmod +x ~/bin/k8s-context

echo "✅ DevOps environment setup complete!"
echo "Please reboot or run 'newgrp docker' to apply group changes"
```

### Project Templates
```bash
# Create project template directories
mkdir -p ~/templates/{terraform,ansible,k8s}

# Terraform template
cat > ~/templates/terraform/main.tf << 'EOF'
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}
EOF

# Ansible template
cat > ~/templates/ansible/playbook.yml << 'EOF'
---
- name: Sample playbook
  hosts: all
  become: yes
  tasks:
    - name: Update package cache
      package:
        update_cache: yes
      
    - name: Install basic packages
      package:
        name:
          - curl
          - wget
          - git
        state: present
EOF

# Kubernetes template
cat > ~/templates/k8s/deployment.yml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app
  labels:
    app: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: app
        image: nginx:latest
        ports:
        - containerPort: 80
EOF
```

## 📊 Monitoring Your Setup

### System Health Check Script
Create `~/bin/devops-health-check.sh`:
```bash
#!/bin/bash
# DevOps Tools Health Check

echo "🏥 DevOps Environment Health Check"
echo "=================================="

# Check Docker
if systemctl is-active --quiet docker; then
    echo "✅ Docker: Running"
    echo "   Version: $(docker --version)"
else
    echo "❌ Docker: Not running"
fi

# Check Kubernetes tools
if command -v kubectl &> /dev/null; then
    echo "✅ kubectl: $(kubectl version --client --short)"
else
    echo "❌ kubectl: Not installed"
fi

# Check cloud CLIs
for cli in aws az gcloud; do
    if command -v $cli &> /dev/null; then
        echo "✅ $cli: Available"
    else
        echo "❌ $cli: Not installed"
    fi
done

# Check Terraform
if command -v terraform &> /dev/null; then
    echo "✅ Terraform: $(terraform version | head -1)"
else
    echo "❌ Terraform: Not installed"
fi

# Check system resources
echo ""
echo "💻 System Resources:"
echo "   CPU: $(nproc) cores"
echo "   RAM: $(free -h | awk '/^Mem:/ {print $2}') total, $(free -h | awk '/^Mem:/ {print $7}') available"
echo "   Disk: $(df -h / | awk 'NR==2 {print $4}') free"

echo ""
echo "🔧 Active containers: $(docker ps --format 'table {{.Names}}\t{{.Status}}' 2>/dev/null | wc -l) running"
echo "📦 Images: $(docker images --format 'table {{.Repository}}' 2>/dev/null | wc -l) total"
```

## 🎯 Workflow Examples

### Daily DevOps Workflow
```bash
# Morning startup routine
echo "alias morning='devops-health-check.sh && kubectl get nodes && docker ps && terraform --version'" >> ~/.bashrc

# Project switching
proj() {
    cd ~/projects/$1
    if [ -f .env ]; then source .env; fi
    if [ -f kubeconfig ]; then export KUBECONFIG=$(pwd)/kubeconfig; fi
    tmux new-session -d -s $1
    tmux send-keys -t $1 "clear && ls -la" Enter
    tmux attach -t $1
}

# Quick deployment
deploy() {
    kubectl apply -f k8s/
    kubectl rollout status deployment/$1
    kubectl get pods -l app=$1
}

# Infrastructure update
infra-update() {
    terraform plan -out=tfplan
    read -p "Apply changes? (y/N): " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        terraform apply tfplan
    fi
}
```

## 🌟 Pro Tips

### Terminal Productivity
1. **Use tmux sessions** for different projects
2. **Create custom scripts** for repetitive tasks
3. **Use aliases** for common commands
4. **Set up auto-completion** for all tools
5. **Use history search** with `Ctrl+R`

### Cloud Cost Optimization
```bash
# AWS cost checking aliases
echo 'alias aws-cost="aws ce get-cost-and-usage --time-period Start=2024-01-01,End=2024-12-31 --granularity MONTHLY --metrics BlendedCost"' >> ~/.bashrc
echo 'alias aws-unused="aws ec2 describe-instances --filters Name=instance-state-name,Values=stopped --query Reservations[].Instances[].[InstanceId,InstanceType]"' >> ~/.bashrc
```

### Security Reminders
- **Rotate credentials** regularly
- **Use IAM roles** instead of access keys when possible
- **Enable MFA** on all cloud accounts
- **Scan containers** before deployment
- **Keep tools updated** to patch vulnerabilities

---

This comprehensive DevOps toolkit will transform your Arch Hyprland Bare system into a powerful cloud engineering workstation. Start with the essentials and gradually add tools as your needs grow.

*Happy DevOps-ing! 🚀*
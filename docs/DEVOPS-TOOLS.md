# 🛠️ DevOps Tools Installation Guide

> **Complete toolkit for cloud professionals and DevOps engineers**

This guide covers installing essential DevOps tools after your base Arch Hyprland installation.

## 🏗️ Container & Orchestration

### Docker & Docker Compose
```bash
# Install Docker
sudo pacman -S docker docker-compose

# Enable and start Docker
sudo systemctl enable --now docker

# Add user to docker group
sudo usermod -aG docker $USER

# Test installation
docker --version
docker-compose --version

# Useful aliases
echo "alias d='docker'" >> ~/.bashrc
echo "alias dc='docker-compose'" >> ~/.bashrc
echo "alias dps='docker ps'" >> ~/.bashrc
echo "alias dimg='docker images'" >> ~/.bashrc
```

### Podman & Buildah (Docker alternative)
```bash
# Install Podman ecosystem
sudo pacman -S podman buildah skopeo

# Configure rootless containers
echo "$USER:165536:65536" | sudo tee -a /etc/subuid
echo "$USER:165536:65536" | sudo tee -a /etc/subgid

# Test installation
podman --version
buildah --version
```

### Kubernetes Tools
```bash
# kubectl - Kubernetes CLI
sudo pacman -S kubectl

# k9s - Kubernetes TUI
yay -S k9s

# Helm - Package manager for Kubernetes
sudo pacman -S helm

# kubectx/kubens - Context switching
yay -S kubectx

# Useful aliases
echo "alias k='kubectl'" >> ~/.bashrc
echo "alias kgp='kubectl get pods'" >> ~/.bashrc
echo "alias kgs='kubectl get services'" >> ~/.bashrc
echo "alias kgd='kubectl get deployments'" >> ~/.bashrc
echo "alias kdp='kubectl describe pod'" >> ~/.bashrc
```

### Container Development Tools
```bash
# Dive - Docker image explorer
yay -S dive

# Trivy - Vulnerability scanner
yay -S trivy

# Hadolint - Dockerfile linter
yay -S hadolint-bin

# Docker Bench Security
yay -S docker-bench-security
```

## ☁️ Cloud Provider CLIs

### AWS CLI v2
```bash
# Install AWS CLI
yay -S aws-cli-v2

# Configure (you'll need AWS credentials)
aws configure

# Useful tools
yay -S awslogs        # CloudWatch logs CLI
yay -S s3cmd          # S3 management
yay -S aws-vault      # Secure credential storage

# Test installation
aws --version
```

### Azure CLI
```bash
# Install Azure CLI
yay -S azure-cli

# Login to Azure
az login

# Useful extensions
az extension add --name application-insights
az extension add --name aks-preview

# Test installation
az --version
```

### Google Cloud SDK
```bash
# Install Google Cloud SDK
yay -S google-cloud-sdk

# Initialize gcloud
gcloud init

# Install additional components
gcloud components install gke-gcloud-auth-plugin
gcloud components install kubectl

# Test installation
gcloud version
```

### DigitalOcean CLI
```bash
# Install doctl
yay -S doctl

# Authenticate
doctl auth init

# Test installation
doctl version
```

## 🏗️ Infrastructure as Code

### Terraform
```bash
# Install Terraform
sudo pacman -S terraform

# Terraform tools
yay -S terraform-docs    # Generate documentation
yay -S tflint           # Terraform linter
yay -S terragrunt       # Terraform wrapper

# Useful aliases
echo "alias tf='terraform'" >> ~/.bashrc
echo "alias tfp='terraform plan'" >> ~/.bashrc
echo "alias tfa='terraform apply'" >> ~/.bashrc
echo "alias tfd='terraform destroy'" >> ~/.bashrc

# Test installation
terraform --version
```

### Pulumi
```bash
# Install Pulumi
yay -S pulumi

# Login to Pulumi
pulumi login

# Test installation
pulumi version
```

### Ansible
```bash
# Install Ansible
sudo pacman -S ansible

# Additional collections
ansible-galaxy collection install community.general
ansible-galaxy collection install ansible.posix

# Useful tools
yay -S ansible-lint     # Ansible linter
sudo pacman -S sshpass  # SSH password support

# Test installation
ansible --version
```

### Packer
```bash
# Install Packer
yay -S packer

# Test installation
packer version
```

## 📊 Monitoring & Observability

### Prometheus Tools
```bash
# Prometheus server
yay -S prometheus

# Node exporter
yay -S prometheus-node-exporter

# Alertmanager
yay -S alertmanager

# Prometheus CLI tools
yay -S promtool
```

### Grafana
```bash
# Install Grafana
yay -S grafana

# Enable and start Grafana
sudo systemctl enable --now grafana

# Grafana CLI
yay -S grafana-cli
```

### ELK Stack Tools
```bash
# Elasticsearch
yay -S elasticsearch

# Logstash
yay -S logstash

# Kibana
yay -S kibana

# Filebeat
yay -S filebeat
```

### Modern Observability
```bash
# Jaeger - Distributed tracing
yay -S jaeger

# OpenTelemetry Collector
yay -S opentelemetry-collector-contrib

# Vector - Log router
yay -S vector
```

## 🔧 CI/CD & Git Tools

### GitHub CLI
```bash
# Install GitHub CLI (already included in base)
sudo pacman -S github-cli

# Authenticate
gh auth login

# Useful extensions
gh extension install github/gh-copilot
gh extension install dlvhdr/gh-dash

# Test installation
gh --version
```

### GitLab CLI
```bash
# Install GitLab CLI
yay -S glab

# Authenticate
glab auth login

# Test installation
glab version
```

### Jenkins Tools
```bash
# Jenkins CLI
yay -S jenkins-cli

# Blue Ocean CLI
yay -S blueocean-cli
```

### ArgoCD CLI
```bash
# ArgoCD CLI
yay -S argocd-cli

# Test installation
argocd version
```

## 🔐 Security & Secrets Management

### HashiCorp Vault
```bash
# Install Vault
yay -S vault

# Test installation
vault version
```

### SOPS - Secrets encryption
```bash
# Install SOPS
yay -S sops

# Age encryption (recommended with SOPS)
sudo pacman -S age

# Test installation
sops --version
```

### Security Scanners
```bash
# Checkov - Infrastructure security scanner
yay -S checkov

# Bandit - Python security linter
sudo pacman -S bandit

# Safety - Python dependency vulnerability scanner
pip install safety

# Grype - Container vulnerability scanner
yay -S grype
```

## 🌐 Networking & Service Mesh

### Istio
```bash
# Install Istio CLI
yay -S istioctl

# Test installation
istioctl version
```

### Linkerd
```bash
# Install Linkerd CLI
yay -S linkerd2-cli

# Test installation
linkerd version
```

### Consul
```bash
# Install Consul
yay -S consul

# Test installation
consul version
```

## 📡 Load Testing & Performance

### Apache Bench
```bash
# Install Apache Bench
sudo pacman -S apache-tools

# Usage example
ab -n 1000 -c 10 http://localhost:8080/
```

### wrk - Modern HTTP benchmarking
```bash
# Install wrk
sudo pacman -S wrk

# Usage example
wrk -t12 -c400 -d30s http://localhost:8080/
```

### K6 - Load testing
```bash
# Install K6
yay -S k6

# Test installation
k6 version
```

## 🔍 API Development & Testing

### Postman
```bash
# Install Postman
yay -S postman-bin

# Alternative: Insomnia
yay -S insomnia
```

### HTTPie - Modern curl
```bash
# Install HTTPie
sudo pacman -S httpie

# Usage examples
http GET https://api.github.com/user
http POST https://httpbin.org/post name=Amir city=Tehran
```

### jq - JSON processor
```bash
# Install jq (essential for API work)
sudo pacman -S jq

# Usage examples
curl -s https://api.github.com/user | jq '.name'
kubectl get pods -o json | jq '.items[].metadata.name'
```

## 🗄️ Database Tools

### Database CLIs
```bash
# PostgreSQL client
sudo pacman -S postgresql-libs

# MySQL client
sudo pacman -S mysql-clients

# Redis CLI
sudo pacman -S redis

# MongoDB tools
yay -S mongodb-tools

# ClickHouse client
yay -S clickhouse-client
```

### Database Management
```bash
# DBeaver - Universal database tool
yay -S dbeaver

# pgAdmin - PostgreSQL admin
yay -S pgadmin4

# MongoDB Compass
yay -S mongodb-compass
```

## 📝 Documentation & Communication

### Markdown Tools
```bash
# Pandoc - Universal document converter
sudo pacman -S pandoc

# Mermaid CLI - Diagram generation
yay -S mermaid-cli

# PlantUML - UML diagrams
sudo pacman -S plantuml
```

### Slack
```bash
# Slack desktop
yay -S slack-desktop
```

### Teams
```bash
# Microsoft Teams
yay -S teams
```

## 🛠️ Development Languages & Frameworks

### Go
```bash
# Install Go
sudo pacman -S go

# Go tools
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install honnef.co/go/tools/cmd/staticcheck@latest

# Test installation
go version
```

### Python
```bash
# Python (already installed)
sudo pacman -S python python-pip python-poetry

# Virtual environment tools
sudo pacman -S python-virtualenv python-pipenv

# Useful Python tools
pip install --user black isort flake8 mypy
```

### Node.js
```bash
# Node.js (already installed)
sudo pacman -S nodejs npm yarn

# Node version manager
yay -S nvm

# Global packages
npm install -g @angular/cli
npm install -g create-react-app
npm install -g vue-cli
npm install -g typescript
```

### Rust
```bash
# Install Rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# Add to PATH
source ~/.cargo/env

# Useful tools
cargo install cargo-edit
cargo install cargo-audit
cargo install cargo-watch
```

## 📊 Quick Installation Scripts

### Essential DevOps Stack
```bash
#!/bin/bash
# Install essential DevOps tools

echo "🚀 Installing essential DevOps tools..."

# Containers
sudo pacman -S docker docker-compose kubectl helm
yay -S k9s lazydocker

# Cloud CLIs
yay -S aws-cli-v2 azure-cli google-cloud-sdk

# Infrastructure
sudo pacman -S terraform ansible
yay -S packer

# Monitoring
yay -S prometheus grafana-cli

# Git & CI/CD
sudo pacman -S github-cli
yay -S glab argocd-cli

# Security
yay -S vault sops

# Utilities
sudo pacman -S jq httpie

echo "✅ Essential DevOps tools installed!"
```

### Cloud Native Stack
```bash
#!/bin/bash
# Install cloud-native development stack

echo "☁️ Installing cloud-native tools..."

# Kubernetes ecosystem
sudo pacman -S kubectl helm
yay -S k9s kubectx istioctl linkerd2-cli

# Container tools
sudo pacman -S docker docker-compose podman buildah
yay -S dive trivy hadolint-bin

# Service mesh
yay -S istioctl linkerd2-cli

# GitOps
yay -S argocd-cli flux-cli

# Observability
yay -S prometheus grafana-cli jaeger
yay -S opentelemetry-collector-contrib

echo "✅ Cloud-native stack installed!"
```

### Security & Compliance
```bash
#!/bin/bash
# Install security and compliance tools

echo "🔐 Installing security tools..."

# Secret management
yay -S vault sops
sudo pacman -S age

# Security scanners
yay -S checkov trivy grype
sudo pacman -S bandit

# Compliance
yay -S terraform-compliance
pip install --user safety

# Network security
sudo pacman -S nmap wireshark-cli
yay -S fierce

echo "✅ Security tools installed!"
```

## 🎯 Recommended Installation Order

### Day 1 - Container Foundation
```bash
# Essential containers
sudo pacman -S docker docker-compose
yay -S lazydocker

# Enable services
sudo systemctl enable --now docker
sudo usermod -aG docker $USER

# Test setup
docker run hello-world
```

### Day 2 - Kubernetes
```bash
# Kubernetes tools
sudo pacman -S kubectl helm
yay -S k9s kubectx

# Practice environment
yay -S kind  # Local Kubernetes
```

### Day 3 - Cloud CLIs
```bash
# Choose your primary cloud
yay -S aws-cli-v2     # For AWS
# OR
yay -S azure-cli      # For Azure
# OR
yay -S google-cloud-sdk  # For GCP
```

### Day 4 - Infrastructure as Code
```bash
# Terraform ecosystem
sudo pacman -S terraform
yay -S terraform-docs tflint

# Configuration management
sudo pacman -S ansible
```

### Week 2 - Advanced Tools
Install monitoring, security, and specialized tools based on your specific needs.

## 💡 Pro Tips

### Aliases for Efficiency
Add these to your `~/.bashrc`:
```bash
# Docker shortcuts
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'

# Kubernetes shortcuts
alias k='kubectl'
alias kgp='kubectl get pods'
alias kgs='kubectl get services'
alias kgd='kubectl get deployments'
alias kns='kubens'
alias kctx='kubectx'

# Terraform shortcuts
alias tf='terraform'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfi='terraform init'

# Git shortcuts
alias g='git'
alias gs='git status'
alias gp='git push'
alias gl='git log --oneline -10'

# System shortcuts
alias ll='eza -la --icons'
alias update='sudo pacman -Syu && yay -Syu'
```

### tmux DevOps Layout
Create a tmux session template for DevOps work:
```bash
# ~/.tmux/devops-session
new-session -d -s devops
split-window -h
split-window -v
select-pane -t 0
send-keys 'cd ~/projects' Enter
send-keys 'ls -la' Enter
select-pane -t 1
send-keys 'k9s' Enter
select-pane -t 2
send-keys 'lazydocker' Enter
select-pane -t 0
```

Load with: `tmux source-file ~/.tmux/devops-session`

---

<div align="center">

**🛠️ DevOps Tools Guide - Arch Hyprland**

*Install tools as needed for your specific workflow*

[🏠 Back to Main](../README.md) • [📖 Documentation](../docs/) • [💬 Community](https://t.me/archlinux_ir)

</div>
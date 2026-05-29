#!/bin/bash

set -e

echo "Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "Installing required packages..."
sudo apt install -y 
ca-certificates 
curl 
gnupg 
lsb-release 
git 
unzip

echo "Installing Docker..."

if ! command -v docker &> /dev/null
then
curl -fsSL https://download.docker.com/linux/debian/gpg | 
sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

```
echo \
  "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
```

fi

echo "Enabling Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Adding current user to docker group..."
sudo usermod -aG docker $USER

echo "Creating 2GB swap file..."
if [ ! -f /swapfile ]; then
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

```
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

fi

echo "Creating required directories..."
mkdir -p nginx/ssl
mkdir -p mysql/data

echo "Starting Docker stack..."
docker compose up -d --build

echo "Bootstrap completed successfully."

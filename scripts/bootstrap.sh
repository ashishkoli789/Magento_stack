#!/bin/bash

set -e

echo "======================================"
echo "Magento EC2 Bootstrap Script"
echo "======================================"

echo "[1/8] Updating system packages..."
sudo apt update && sudo apt upgrade -y

echo "[2/8] Installing required packages..."
sudo apt install -y 
ca-certificates 
curl 
gnupg 
lsb-release 
git 
ufw 
unzip

echo "[3/8] Installing Docker..."

sudo install -m 0755 -d /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | 
sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo 
"deb [arch=$(dpkg --print-architecture) 
signed-by=/etc/apt/keyrings/docker.gpg] 
https://download.docker.com/linux/debian 
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | 
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update

sudo apt install -y 
docker-ce 
docker-ce-cli 
containerd.io 
docker-buildx-plugin 
docker-compose-plugin

echo "[4/8] Enabling Docker service..."

sudo systemctl enable docker
sudo systemctl start docker

echo "[5/8] Creating application group..."

if ! getent group clp > /dev/null; then
sudo groupadd clp
fi

echo "[6/8] Adding current user to docker group..."

sudo usermod -aG docker $USER

echo "[7/8] Creating swap file..."

if [ ! -f /swapfile ]; then
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

fi

echo "[8/8] Configuring firewall..."

sudo ufw allow OpenSSH
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

sudo ufw --force enable

echo "======================================"
echo "Bootstrap completed successfully."
echo "======================================"

echo "Logout/login recommended for docker group changes."

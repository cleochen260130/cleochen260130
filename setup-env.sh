#!/bin/bash
# =================================================================
# OPSIS Environment Setup Script
# Description: One-liner to provision Ubuntu VM for Buildroot
# Author: Cleo (AI Assistant) for Elvis
# =================================================================

set -e

echo "🚀 Starting OPSIS Environment Setup..."

# 1. Update and Install Dependencies
echo "📦 Installing system dependencies..."
sudo apt-get update
sudo apt-get install -y \
    build-essential \
    git \
    wget \
    cpio \
    unzip \
    rsync \
    bc \
    libssl-dev \
    python3 \
    qemu-system-arm \
    net-tools \
    openssh-server \
    curl

# 2. Setup Google Repo Tool
echo "🛠️ Installing Google Repo tool..."
mkdir -p ~/bin
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo

# Add ~/bin to PATH if not already present
if ! grep -q 'export PATH=~/bin:$PATH' ~/.bashrc; then
    echo 'export PATH=~/bin:$PATH' >> ~/.bashrc
    echo "✅ Added ~/bin to PATH in .bashrc"
fi

# 3. Configure SSH Server
echo "🔒 Configuring SSH Server (Password Authentication)..."
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
sudo sed -i 's/^#PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^#KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/^KbdInteractiveAuthentication.*/KbdInteractiveAuthentication yes/' /etc/ssh/sshd_config

sudo systemctl restart ssh
echo "✅ SSH configured and restarted."

# 4. Final Touches
echo "✨ Setup Complete!"
echo "-------------------------------------------------------"
echo "Next steps:"
echo "1. Run: source ~/.bashrc"
echo "2. Run: sudo passwd ubuntu (to set your login password)"
echo "3. Run: ssh-keygen -t ed25519 (for GitHub access)"
echo "-------------------------------------------------------"

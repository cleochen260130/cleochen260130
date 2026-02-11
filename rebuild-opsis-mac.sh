#!/bin/bash
# =================================================================
# OPSIS Builder Rebuild Script (v2 - with Persistent Mounting)
# Description: Recreates VM and mounts local Mac workspace
# Author: Cleo (AI Assistant) for Elvis
# =================================================================

VM_NAME="opsis-builder"
NETWORK_IF="en6" # Wired Ethernet
HOST_WS_PATH="$HOME/opsis-workspace" # Mac path

echo "-------------------------------------------------------"
echo "🛠️  Starting Persistent OPSIS Builder Rebuild..."
echo "-------------------------------------------------------"

# 0. Ensure Host Directory exists
mkdir -p "$HOST_WS_PATH"
echo "📁 Host workspace path: $HOST_WS_PATH"

# 1. Purge old instance
echo "🗑️  Step 1: Deleting existing VM ($VM_NAME)..."
multipass delete --purge "$VM_NAME" 2>/dev/null || echo "   (No existing VM found)"

# 2. Launch new instance
echo "🚀 Step 2: Launching new VM (Ubuntu 24.04)..."
multipass launch 24.04 \
  --name "$VM_NAME" \
  --cpus 4 \
  --memory 8G \
  --disk 40G \
  --network "$NETWORK_IF"

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to launch VM."
    exit 1
fi

# 3. Mount Workspace
echo "🔗 Step 3: Mounting host workspace to VM..."
multipass mount "$HOST_WS_PATH" "$VM_NAME:/home/ubuntu/opsis-workspace"

# 4. Automatic Environment Setup
echo "⏳ Step 4: Waiting for VM to be ready..."
sleep 5

echo "📦 Step 5: Running automated environment setup..."
multipass exec "$VM_NAME" -- bash -c "curl -sSL https://raw.githubusercontent.com/cleochen260130/cleochen260130/main/setup-env.sh | bash"

echo "-------------------------------------------------------"
echo "✅ SUCCESS: $VM_NAME is ready and workspace is mounted!"
echo "-------------------------------------------------------"
echo "Your code is safe at: $HOST_WS_PATH"
echo "VM path: ~/opsis-workspace"
echo "-------------------------------------------------------"

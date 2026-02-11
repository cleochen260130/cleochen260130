#!/bin/bash
# =================================================================
# OPSIS Builder Rebuild Script (for macOS)
# Description: Purges and recreates the Multipass VM with setup
# Author: Cleo (AI Assistant)
# =================================================================

VM_NAME="opsis-builder"
NETWORK_IF="en6" # Wired Ethernet

echo "-------------------------------------------------------"
echo "🛠️  Starting OPSIS Builder Rebuild Process..."
echo "-------------------------------------------------------"

# 1. Purge old instance
echo "🗑️  Step 1: Deleting existing VM ($VM_NAME)..."
multipass delete --purge "$VM_NAME" 2>/dev/null || echo "   (No existing VM found to delete)"

# 2. Launch new instance
echo "🚀 Step 2: Launching new VM (Ubuntu 24.04)..."
echo "   Config: 4 CPUs, 8GB RAM, 40GB Disk, Bridge to $NETWORK_IF"
multipass launch 24.04 \
  --name "$VM_NAME" \
  --cpus 4 \
  --memory 8G \
  --disk 40G \
  --network "$NETWORK_IF"

if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to launch VM. Please check if $NETWORK_IF is connected."
    exit 1
fi

# 3. Automatic Environment Setup
echo "⏳ Step 3: Waiting for VM to be ready..."
sleep 5

echo "📦 Step 4: Running automated environment setup..."
multipass exec "$VM_NAME" -- bash -c "curl -sSL https://raw.githubusercontent.com/cleochen260130/cleochen260130/main/setup-env.sh | bash"

echo "-------------------------------------------------------"
echo "✅ SUCCESS: $VM_NAME is ready!"
echo "-------------------------------------------------------"
echo "Next steps:"
echo "1. Enter VM: multipass shell $VM_NAME"
echo "2. Inside VM, set password: sudo passwd ubuntu"
echo "3. Verify bridge IP: ip addr show br0 (if setup-bridge was run)"
echo "-------------------------------------------------------"

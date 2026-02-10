#!/bin/bash
# =================================================================
# OPSIS Bridge Networking Setup Script (V3 - Precision Version)
# Description: Configures br0 on a SPECIFIED or DETECTED interface
# =================================================================

set -e

echo "🔍 Scanning network interfaces..."

# 1. Get List of candidate interfaces (excluding lo, br, docker, etc.)
CANDIDATES=($(ip -br link show | awk '$1 !~ /lo|br0|docker|veth/ {print $1}'))

# 2. Determine target interface
TARGET_IF=$1

if [ -z "$TARGET_IF" ]; then
    echo "❓ No interface specified. Candidates found:"
    for i in "${!CANDIDATES[@]}"; do
        echo "  [$i] ${CANDIDATES[$i]}"
    done
    
    # If only one candidate (unlikely in multi-NIC setup), pick it
    if [ ${#CANDIDATES[@]} -eq 1 ]; then
        TARGET_IF=${CANDIDATES[0]}
        echo "➡️  Only one candidate found, choosing $TARGET_IF"
    else
        # Suggest the second interface (usually the one added via --network)
        if [ ${#CANDIDATES[@]} -ge 2 ]; then
            TARGET_IF=${CANDIDATES[1]}
            echo "💡 Tip: Usually the second interface (${CANDIDATES[1]}) is the one from --network."
        fi
        echo "⚠️  Please run: bash setup-bridge.sh <interface_name>"
        echo "Example: bash setup-bridge.sh enp0s2"
        exit 1
    fi
fi

# Validate target
if [[ ! " ${CANDIDATES[@]} " =~ " ${TARGET_IF} " ]]; then
    echo "❌ Error: Interface '$TARGET_IF' not found or is invalid."
    exit 1
fi

MAC=$(cat /sys/class/net/"$TARGET_IF"/address)
echo "✅ Targeting Interface: $TARGET_IF (MAC: $MAC)"

# 3. Backup existing netplan configs
echo "📦 Backing up existing netplan configs..."
sudo mkdir -p /etc/netplan/backup
sudo mv /etc/netplan/*.yaml /etc/netplan/backup/ 2>/dev/null || true

# 4. Create the Netplan configuration
echo "📝 Generating /etc/netplan/99-bridge.yaml..."

sudo tee /etc/netplan/99-bridge.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $TARGET_IF:
      dhcp4: false
      dhcp6: false
      optional: true
  bridges:
    br0:
      interfaces: [$TARGET_IF]
      dhcp4: true
      macaddress: $MAC
      parameters:
        stp: false
        forward-delay: 0
EOF

# 5. Apply the configuration
echo "🔄 Applying Netplan configuration..."
sudo netplan apply

echo "-------------------------------------------------------"
echo "🎉 Bridge Setup Attempted on $TARGET_IF!"
echo "-------------------------------------------------------"
brctl show br0
ip -4 addr show br0 || echo "⏳ Waiting for IP assignment..."
echo "-------------------------------------------------------"

#!/bin/bash
# =================================================================
# OPSIS Bridge Networking Setup Script
# Description: Automatically configures br0 on top of the physical interface
# Author: Cleo (AI Assistant) for Elvis
# =================================================================

set -e

echo "🔍 Detecting network environment..."

# 1. Detect the primary physical interface (excluding lo and existing bridges)
# We look for the first interface that has an IP address or is up
IFACE=$(ip -br link show | awk '$1 !~ /lo|br0|docker/ {print $1; exit}')

if [ -z "$IFACE" ]; then
    echo "❌ Error: Could not detect physical interface."
    exit 1
fi

MAC=$(cat /sys/class/net/"$IFACE"/address)

echo "✅ Target Interface: $IFACE"
echo "✅ MAC Address: $MAC"

# 2. Create the Netplan configuration
# Note: We use 99-bridge.yaml to ensure it overrides default configs
echo "📝 Generating /etc/netplan/99-bridge.yaml..."

sudo tee /etc/netplan/99-bridge.yaml > /dev/null <<EOF
network:
  version: 2
  ethernets:
    $IFACE:
      dhcp4: false
      dhcp6: false
  bridges:
    br0:
      interfaces: [$IFACE]
      dhcp4: true
      macaddress: $MAC
      parameters:
        stp: false
        forward-delay: 0
EOF

# 3. Apply the configuration
echo "🔄 Applying Netplan configuration..."
echo "⚠️  Note: You might lose connection briefly if you are using this interface for SSH."

# Using 'netplan apply' is more forceful than 'try'
sudo netplan apply

echo "-------------------------------------------------------"
echo "🎉 Bridge Setup Complete!"
echo "-------------------------------------------------------"
echo "Current Network Status (br0):"
ip -4 addr show br0 || echo "❌ br0 not found or no IP assigned."
echo "-------------------------------------------------------"

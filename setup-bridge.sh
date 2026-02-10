#!/bin/bash
# =================================================================
# OPSIS Bridge Networking Setup Script (V2 - Robust Version)
# Description: Automatically configures br0 and binds physical IF
# =================================================================

set -e

echo "🔍 Detecting network environment..."

# 1. Detect the primary physical interface
# We skip 'lo', 'br0', 'docker', 'veth'
IFACE=$(ip -br link show | awk '$1 !~ /lo|br0|docker|veth/ {print $1; exit}')

if [ -z "$IFACE" ]; then
    echo "❌ Error: Could not detect physical interface."
    exit 1
fi

MAC=$(cat /sys/class/net/"$IFACE"/address)

echo "✅ Target Interface: $IFACE"
echo "✅ MAC Address: $MAC"

# 2. Backup existing netplan configs to avoid conflicts
echo "📦 Backing up existing netplan configs..."
sudo mkdir -p /etc/netplan/backup
sudo mv /etc/netplan/*.yaml /etc/netplan/backup/ 2>/dev/null || true

# 3. Create the Netplan configuration
echo "📝 Generating /etc/netplan/99-bridge.yaml..."

sudo tee /etc/netplan/99-bridge.yaml > /dev/null <<EOF
network:
  version: 2
  renderer: networkd
  ethernets:
    $IFACE:
      dhcp4: false
      dhcp6: false
      optional: true
  bridges:
    br0:
      interfaces: [$IFACE]
      dhcp4: true
      macaddress: $MAC
      parameters:
        stp: false
        forward-delay: 0
EOF

# 4. Apply the configuration
echo "🔄 Applying Netplan configuration..."
sudo netplan apply

# Give it a few seconds to settle
sleep 2

echo "-------------------------------------------------------"
echo "🎉 Bridge Setup Attempted!"
echo "-------------------------------------------------------"
echo "Bridge Status (brctl):"
brctl show br0
echo ""
echo "IP Status (br0):"
ip -4 addr show br0 || echo "❌ No IP assigned to br0 yet."
echo "-------------------------------------------------------"
echo "If 'interfaces' is still empty, please check 'dmesg | grep br0'"

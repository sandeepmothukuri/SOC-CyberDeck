#!/bin/bash

# SOC-CyberDeck Network Interface Update Script
# This script can be run anytime to update the network interface configuration
# Usage: ./update-network-interface.sh [--restart-suricata]

set -e

echo "🔍 SOC-CyberDeck Network Interface Update Script"
echo "================================================"

# Change to the SOC-CyberDeck directory
cd "$(dirname "$0")"

# ----------------------------
# Dynamic Interface Detection
# ----------------------------
echo "🔍 Detecting primary network interface..."

# Method 1: Try to get the default route interface (most reliable)
DETECTED_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)

# Method 2: Fallback to first active non-loopback interface
if [ -z "$DETECTED_IFACE" ]; then
    echo "⚠️  No default route found, trying alternative detection..."
    DETECTED_IFACE=$(ip link show | grep -E '^[0-9]+:' | grep -v lo | grep 'state UP' | awk -F': ' '{print $2}' | head -1)
fi

# Method 3: Final fallback to any UP interface except loopback
if [ -z "$DETECTED_IFACE" ]; then
    echo "⚠️  Trying final fallback method..."
    DETECTED_IFACE=$(ip a | grep 'state UP' | grep -v lo | awk -F: '{print $2}' | head -1 | xargs)
fi

if [ -z "$DETECTED_IFACE" ]; then
    echo "❌ Could not detect any suitable network interface."
    echo "📋 Available interfaces:"
    ip link show | grep -E '^[0-9]+:' | awk -F': ' '{print "   - " $2}' | sed 's/@.*$//'
    echo ""
    echo "💡 Please manually set SURICATA_INT in .env file"
    exit 1
fi

echo "✅ Detected interface: $DETECTED_IFACE"

# ----------------------------
# Update .env file
# ----------------------------
ENV_FILE=".env"

if [ ! -f "$ENV_FILE" ]; then
    echo "❌ Error: .env file not found in current directory"
    echo "💡 Make sure you're running this script from the SOC-CyberDeck directory"
    exit 1
fi

# Show current setting if it exists
if grep -q "^SURICATA_INT=" "$ENV_FILE"; then
    CURRENT_IFACE=$(grep "^SURICATA_INT=" "$ENV_FILE" | cut -d'=' -f2)
    echo "📋 Current SURICATA_INT: $CURRENT_IFACE"
    
    if [ "$CURRENT_IFACE" = "$DETECTED_IFACE" ]; then
        echo "✅ Interface is already correctly configured!"
    else
        echo "🔄 Updating SURICATA_INT from $CURRENT_IFACE to $DETECTED_IFACE..."
        # Create backup
        cp "$ENV_FILE" "$ENV_FILE.backup.$(date +%Y%m%d_%H%M%S)"
        # Update the interface
        sed -i "s/^SURICATA_INT=.*/SURICATA_INT=$DETECTED_IFACE/" "$ENV_FILE"
        echo "✅ SURICATA_INT updated to: $DETECTED_IFACE"
    fi
else
    echo "➕ Adding SURICATA_INT to .env file..."
    echo "SURICATA_INT=$DETECTED_IFACE" >> "$ENV_FILE"
    echo "✅ SURICATA_INT added as: $DETECTED_IFACE"
fi

# ----------------------------
# Restart Suricata if requested
# ----------------------------
if [ "$1" = "--restart-suricata" ] || [ "$1" = "-r" ]; then
    echo "🔄 Restarting Suricata with new interface configuration..."
    
    if command -v docker-compose &> /dev/null; then
        echo "🛑 Stopping Suricata..."
        sudo docker-compose stop suricata 2>/dev/null || true
        
        echo "🚀 Starting Suricata with interface $DETECTED_IFACE..."
        sudo docker-compose up -d suricata
        
        echo "⏳ Waiting for Suricata to initialize..."
        sleep 5
        
        echo "📊 Checking Suricata status..."
        if sudo docker-compose ps suricata | grep -q "Up"; then
            echo "✅ Suricata is running successfully!"
        else
            echo "⚠️  Suricata status check - please verify manually with: sudo docker-compose ps suricata"
        fi
    else
        echo "⚠️  docker-compose not found. Please restart Suricata manually."
    fi
fi

echo ""
echo "✅ Network interface configuration update complete!"
echo "📋 Final configuration:"
grep "^SURICATA_INT=" "$ENV_FILE"
echo ""
echo "💡 To restart Suricata with the new configuration, run:"
echo "   sudo docker-compose restart suricata"
echo ""
echo "🔍 To view Suricata events in Evebox, visit:"
echo "   http://localhost:7015"

#!/bin/bash
# Backward compatibility wrapper for cyberdeck_install.sh
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Executing SOC-CyberDeck installation: $SCRIPT_DIR/cyberdeck_install.sh"
exec bash "$SCRIPT_DIR/cyberdeck_install.sh" "$@"
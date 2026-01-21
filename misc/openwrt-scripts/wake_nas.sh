#!/bin/sh

# 'br-lan' is a name of the broadcasting network the target belongs to
# MAC address belongs to a physical machine that needs to be started (NAS)

echo "Booting NAS..."
etherwake -D -i 'br-lan' "6C:1F:F7:8E:3E:D2"
echo "Signal sent."

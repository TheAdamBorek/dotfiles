#!/bin/bash
# Lists physical iOS devices connected to this Mac

devices=$(xcrun xctrace list devices 2>/dev/null | sed -n '/== Devices ==/,/== Simulators ==/p' | grep -v '== ' | grep -v "^$")

if [ -z "$devices" ]; then
    echo "No devices connected."
    exit 0
fi

echo "$devices"

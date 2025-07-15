#!/bin/bash

# Script to run GTK application locally on Raspberry Pi
# This script should be run directly on the Pi's desktop environment

echo "Starting GTK application locally on Raspberry Pi..."

# Check if we have a display
if [ -z "$DISPLAY" ]; then
    echo "Setting up display environment..."
    export DISPLAY=:0
fi

# Run the application
echo "Running gtk_app..."
./gtk_app

echo "GTK application finished."

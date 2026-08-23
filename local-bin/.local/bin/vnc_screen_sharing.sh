#!/bin/bash
# Config
RES="1920x1080"
PORT="5900"
DISPLAY_NAME="TabletDisplay"
#PASSWORD=$(openssl rand -base64 12) # Generates a random one-time password
PASSWORD="z5rm-BwG"
#echo "--------------------------------------------------"
#echo "Setting up secure tablet display..."
#echo "Password: $PASSWORD"
#echo "--------------------------------------------------"

# 1. Start the virtual monitor (Krfb headless server)
# This bypasses the desktop sharing prompt and creates a new output
krfb-virtualmonitor --name "$DISPLAY_NAME" --resolution "$RES" \
  --password "$PASSWORD" --port "$PORT" &
KRFB_PID=$!

#echo "Virtual monitor active. PID: $KRFB_PID"
#echo "To connect securely from your tablet:"
#echo "1. Open a terminal on your tablet (Termux, etc.)"
#echo "2. Run: ssh -L 5901:localhost:$PORT your_user@$(hostname -I | awk '{print $1}')"
#echo "3. Connect your VNC app to 'localhost:5901'"

# Keep script running to maintain the display
trap 'kill "$KRFB_PID"; exit' SIGINT SIGTERM
wait

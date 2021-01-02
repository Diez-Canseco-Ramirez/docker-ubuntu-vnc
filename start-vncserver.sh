#!/bin/bash

echo "starting VNC server ..."
#export USER=root
#sudo vncserver :1 -geometry 1280x800 -depth 24
vncserver :1 -geometry 1280x800 -depth 24
 #&& tail -F /root/.vnc/*.log

echo "starting audio server"

#pulseaudio -D --system --exit-idle-time=-1
pacmd load-module module-virtual-sink sink_name=v1
pacmd set-default-sink v1
pulseaudio -v
#pacmd set-default-source v1.monitor
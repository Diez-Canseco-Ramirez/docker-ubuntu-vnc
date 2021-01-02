#!/bin/bash

echo "starting VNC server ..."
#export USER=root
#sudo vncserver :1 -geometry 1280x800 -depth 24
vncserver :1 -geometry 1280x800 -depth 24 && tail -F /root/.vnc/*.log

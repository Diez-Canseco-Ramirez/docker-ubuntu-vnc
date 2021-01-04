#!/bin/bash

echo "starting audio server"

#pulseaudio -D --system --exit-idle-time=-1
pacmd load-module module-virtual-sink sink_name=v1
pacmd set-default-sink v1
pulseaudio -D
#pacmd set-default-source v1.monitor

echo "starting web socket for VNC server"
websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 6080 localhost:5901

#echo "starting rclone mount"
#rclone mount gcs:docker-videos /root/gcs/

#echo "starting gcsfuse mount"
#export GOOGLE_APPLICATION_CREDENTIALS="/root/cs230-spring2020-8fc12c15efc5.json"
#gcsfuse docker-videos ~/gcs

echo "starting VNC server ..."
#export USER=root
#sudo vncserver :1 -geometry 1280x800 -depth 24
vncserver :1 -geometry 1280x800 -depth 24 && tail -F /root/.vnc/*.log

#echo "starting flask server"
# solves some unknown issue
#export LC_ALL=C.UTF-8
#export LANG=C.UTF-8
#export FLASK_APP=/root/flask_app/hello.py
# flask needs to bind to 0.0.0.0 otherwise will only listen for local container requests
#flask run --host=0.0.0.0 --port=8080
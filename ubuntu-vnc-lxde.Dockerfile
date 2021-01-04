# check if works with stable
FROM ubuntu:18.04

RUN apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends tzdata

RUN dpkg-reconfigure -f noninteractive tzdata

# Install packages
RUN apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends wget curl rsync netcat mg vim bzip2 zip unzip && \
    apt-get install -y --no-install-recommends libx11-6 libxcb1 libxau6 && \
    apt-get install -y --no-install-recommends lxde tightvncserver xvfb dbus-x11 x11-utils && \
    apt-get install -y --no-install-recommends xfonts-base xfonts-75dpi xfonts-100dpi && \
    apt-get install -y --no-install-recommends libssl-dev

RUN apt-get autoclean -y && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Reinstall since lxde appears to have been removed
RUN apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends lxde tightvncserver xvfb dbus-x11 x11-utils

#WORKDIR /root/
#ENV USER neon

RUN echo "force update4"

#Install Google Chrome
RUN mkdir -p /root/downloads
WORKDIR /root/downloads
RUN wget --no-check-certificate https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y fonts-liberation ca-certificates libgbm1 libnspr4 libnss3 xdg-utils
RUN dpkg -i google-chrome-stable_current_amd64.deb

# Install Firefox
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y firefox

# Install Zoom
RUN mkdir -p /root/downloads
WORKDIR /root/downloads
RUN wget https://zoom.us/client/latest/zoom_amd64.deb
RUN apt-get update -q && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y libgl1-mesa-glx libegl1-mesa libxcb-xtest0 libxcb-keysyms1 libxcb-randr0 libxcb-image0 libpulse0 libxslt1.1 ibus libxcb-xinerama0 libxkbcommon-x11-0
#RUN chmod 770 zoom_amd64.deb
RUN dpkg -i zoom_amd64.deb

RUN echo "force update"

# Configuring tightvnc with password
RUN mkdir -p /root/.vnc
COPY xstartup /root/.vnc
RUN chmod a+x /root/.vnc/xstartup
#RUN touch /root/.vnc/passwd
#RUN cat /root/.vnc/passwd
RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd"
#RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd" > /root/.vnc/passwd
#TODO does not save password, have to manually create one after starting container
#RUN "echo 'password\npassword\nn'" | vncpasswd | tee /root/.vnc/passwd
#RUN /bin/bash -c vncserver
#RUN whoami
#RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncserver"
#RUN chmod 400 /root/.vnc/passwd
#RUN chmod 0660 /root/.vnc/passwd
#RUN chmod go-rwx /root/.vnc
RUN touch /root/.Xauthority

# Install Flask
# to satisfy cloud run listening port requirements
RUN apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y --no-install-recommends python3-pip python-dev python-qt4 python3-venv
COPY flask_app/ /root/flask_app/
RUN cd /root/flask_app && \
    python3 -m venv venv && \
    #source venv/bin/activate && \
    pip3 install Flask

# Install simplescreenrecorder
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y simplescreenrecorder

RUN echo "mycontainer" | tee /etc/hostname
RUN echo "127.0.0.1	localhost" | tee /etc/hosts
RUN echo "127.0.0.1	mycontainer" | tee -a /etc/hosts

# Configure audio
RUN apt-get update && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get -y install pulseaudio socat && \
    apt-get -y install alsa-utils
#RUN pulseaudio -D --system --exit-idle-time=-1
    #pacmd load-module module-pipe-sink file=/dev/audio format=s16 rate=44100 channels=2
#RUN pacmd load-module module-virtual-sink sink_name=v1 && \
#    pacmd set-default-sink v1 && \
#    pacmd set-default-source v1.monitor


# Install components for noVNC access with web-browser
RUN apt-get update -q && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt -y install novnc websockify python-numpy
RUN cd /etc/ssl && \
    # threw up error about cannot load /root/.rnd (possibly investigate further)
    printf 'US\nVirginia\nAlexandria\nDiez Canseco Ramirez\n\n\nalfred.wechselberger@diezcansecoramirez.com\n' | openssl req -x509 -nodes -newkey rsa:2048 -keyout novnc.pem -out novnc.pem -days 365
RUN cd /etc/ssl && \
    chmod 644 novnc.pem
RUN apt-get update -q && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y ufw
    #apt-get install -y iptables
RUN ufw allow 6080/tcp
#RUN iptables -I INPUT -p tcp --dport 6080 -j ACCEPT && \
#    iptables -I OUTPUT -p tcp --dport 6080 -j ACCEPT && \
#    service iptables save
#RUN mkdir -p /root/share/ && \
    #apt-get install -y git && \
    #git clone https://github.com/novnc/noVNC

# Install gsutil
#RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
RUN apt-get update -q && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y apt-transport-https ca-certificates gnupg
RUN echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update -q && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y google-cloud-sdk
#RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Install rclone
RUN apt-get update -q && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y rclone
RUN mkdir /root/gcs && \
    mkdir -p /root/.config/rclone/
#COPY rclone.conf /root/.config/rclone/
# fixing error about missing fusemount
RUN apt install -y fuse

# Configure rclone gcs remote
#RUN printf 'n\ngcs\n12\n\n\n225191797750\n\n4\n2\nfalse\n18\n3\nn\n4/1AY0e-g6GbSD-Fghx2iVNVJmkAAAXI5naeiMz4_UuxL-bzpfoBUa1iKYsszU\ny\nq\n' | rclone config

# Install gcsfuse
RUN export GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` && \
    echo "deb http://packages.cloud.google.com/apt $GCSFUSE_REPO main" | tee /etc/apt/sources.list.d/gcsfuse.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
RUN apt-get update -q && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y gcsfuse
#COPY cs230-spring2020-8fc12c15efc5.json /root/

# Install ssh
RUN apt-get update -q && \
    export DEBIAN_FRONTEND=noninteractive && \
    apt-get install -y ssh

RUN echo "force update"

COPY start-vncserver.sh /root
RUN chmod a+x /root/start-vncserver.sh

EXPOSE 5901 8080
ENV USER root
WORKDIR /root
CMD [ "/root/start-vncserver.sh" ]
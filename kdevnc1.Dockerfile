# check if works with stable
FROM kdeneon/plasma

RUN sudo apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -y --no-install-recommends tzdata

RUN sudo dpkg-reconfigure -f noninteractive tzdata

# Install packages
RUN sudo apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -y --no-install-recommends wget curl rsync netcat mg vim bzip2 zip unzip && \
    sudo apt-get install -y --no-install-recommends libx11-6 libxcb1 libxau6 && \
    sudo apt-get install -y --no-install-recommends lxde tightvncserver xvfb dbus-x11 x11-utils && \
    sudo apt-get install -y --no-install-recommends xfonts-base xfonts-75dpi xfonts-100dpi && \
    sudo apt-get install -y --no-install-recommends libssl-dev

#RUN sudo apt-get install -y --no-install-recommends python-pip python-dev python-qt4

RUN sudo apt-get autoclean -y && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

# Reinstall since lxde appears to have been removed
RUN sudo apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -y --no-install-recommends lxde tightvncserver xvfb dbus-x11 x11-utils

#WORKDIR /root/
#ENV USER neon

RUN echo "force update4"

#Install Google Chrome
#RUN mkdir -p /home/neon/downloads
#WORKDIR /home/neon/downloads
#RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
#RUN sudo apt-get update && \
#    sudo apt-get install -y fonts-liberation
#RUN sudo dpkg -i google-chrome-stable_current_amd64.deb

# Install Zoom
#RUN mkdir -p /home/neon/downloads
#WORKDIR /home/neon/downloads
#RUN wget https://zoom.us/client/latest/zoom_amd64.deb
#RUN sudo apt-get update -q && \
#    sudo apt-get install -y libgl1-mesa-glx libegl1-mesa libxcb-xtest0
#RUN sudo chmod 770 zoom_amd64.deb
#RUN sudo dpkg -i zoom_amd64.deb

RUN echo "force update"

# Install tightvnc with password
RUN mkdir -p /home/neon/.vnc
COPY xstartup /home/neon/.vnc
RUN sudo chmod a+x /home/neon/.vnc/xstartup
#RUN touch /home/neon/.vnc/passwd
#RUN cat /home/neon/.vnc/passwd
RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd"
#RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd" > /home/neon/.vnc/passwd
#TODO does not save password, have to manually create one after starting container
#RUN "echo 'password\npassword\nn'" | vncpasswd | tee /home/neon/.vnc/passwd
#RUN /bin/bash -c vncserver
#RUN whoami
#RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncserver"
#RUN sudo chmod 400 /home/neon/.vnc/passwd
#RUN chmod 0660 /home/neon/.vnc/passwd
#RUN sudo chmod go-rwx /home/neon/.vnc
RUN touch /home/neon/.Xauthority

COPY start-vncserver.sh /home/neon
RUN sudo chmod a+x /home/neon/start-vncserver.sh

RUN echo "mycontainer" | sudo tee /etc/hostname
RUN echo "127.0.0.1	localhost" | sudo tee /etc/hosts
RUN echo "127.0.0.1	mycontainer" | sudo tee -a /etc/hosts

EXPOSE 5901
#ENV USER root
WORKDIR ~
CMD [ "/home/neon/start-vncserver.sh" ]
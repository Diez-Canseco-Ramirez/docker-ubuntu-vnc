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
    sudo apt-get install -y --no-install-recommends xfonts-base xfonts-75dpi xfonts-100dpi

#RUN sudo apt-get install -y --no-install-recommends python-pip python-dev python-qt4

RUN sudo apt-get install -y --no-install-recommends libssl-dev

RUN sudo apt-get autoclean -y && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

WORKDIR /root/

RUN sudo mkdir -p /root/.vnc
COPY xstartup /root/.vnc/
RUN sudo chmod a+x /root/.vnc/xstartup
RUN sudo touch /root/.vnc/passwd
#RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd" > /root/.vnc/passwd
RUN echo "-e 'password\npassword\nn' | vncpasswd" | sudo tee /root/.vnc/passwd
RUN sudo chmod 400 /root/.vnc/passwd
RUN sudo chmod go-rwx /root/.vnc
RUN sudo touch /root/.Xauthority

RUN echo "force update"

COPY start-vncserver.sh /root/
RUN sudo chmod a+x /root/start-vncserver.sh

RUN echo "mycontainer" | sudo tee /etc/hostname
RUN echo "127.0.0.1	localhost" | sudo tee /etc/hosts
RUN echo "127.0.0.1	mycontainer" | sudo tee -a /etc/hosts

EXPOSE 5901
ENV USER root
WORKDIR ~
CMD [ "sudo /root/start-vncserver.sh" ]
FROM kdeneon/plasma
MAINTAINER Marco Pantaleoni <marco.pantaleoni@gmail.com>
# Modified by Alfred Wechselberger

#RUN echo "Europe/Rome" > /etc/timezone
# RUN sudo ln -fs /usr/share/zoneinfo/Europe/Rome /etc/localtime

RUN sudo apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -y --no-install-recommends tzdata

RUN sudo dpkg-reconfigure -f noninteractive tzdata

# Install packages
RUN sudo apt-get update -q && \
	export DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -y --no-install-recommends wget curl rsync netcat mg vim bzip2 zip unzip && \
    sudo sudo apt-get install -y --no-install-recommends libx11-6 libxcb1 libxau6 && \
    sudo apt-get install -y --no-install-recommends lxde tightvncserver xvfb dbus-x11 x11-utils && \
    sudo apt-get install -y --no-install-recommends xfonts-base xfonts-75dpi xfonts-100dpi

#RUN apt-get install -y --no-install-recommends python-pip python-dev python-qt4

RUN sudo apt-get install -y --no-install-recommends libssl-dev && \
    sudo apt-get autoclean -y && \
    sudo apt-get autoremove -y && \
    sudo apt-get clean && \
    sudo rm -rf /var/lib/apt/lists/*

WORKDIR /home/neon/

RUN mkdir -p /home/neon/.vnc
COPY xstartup /home/neon/.vnc/
RUN sudo chmod a+x /home/neon/.vnc/xstartup
RUN touch /home/neon/.vnc/passwd
#RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd" > /root/.vnc/passwd
RUN /bin/bash -c "echo -e 'password\npassword\nn' | vncpasswd"
#RUN sudo chmod 400 /home/neon/.vnc/passwd
RUN sudo chmod go-rwx /home/neon/.vnc
RUN touch /home/neon/.Xauthority

COPY start-vncserver.sh /home/neon/
RUN sudo chmod a+x /home/neon/start-vncserver.sh

RUN echo "mycontainer" | sudo tee /etc/hostname
RUN echo "127.0.0.1	localhost" | sudo tee /etc/hosts
RUN echo "127.0.0.1	mycontainer" | sudo tee -a /etc/hosts

EXPOSE 5901
ENV USER neon
WORKDIR ~
CMD [ "/home/neon/start-vncserver.sh" ]
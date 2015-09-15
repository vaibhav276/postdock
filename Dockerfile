FROM ubuntu:14.04
MAINTAINER Vaibhav Pujari <vaibhav276@yahoo.co.in>

# Setup docker user
RUN adduser --gecos 'Docker user' docker && \
adduser docker sudo && \
echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers && \
passwd -d docker

USER docker

ENV PGROOT /home/docker/postgres
ENV PGSRCROOT $PGROOT/source

# Download dependencies for development
RUN sudo apt-get update && \
sudo apt-get install -y libreadline-dev && \
sudo apt-get install -y zlib1g-dev && \
sudo apt-get install -y bison && \
sudo apt-get install -y flex && \
sudo apt-get install -y gcc && \
sudo apt-get install -y make && \
sudo apt-get install -y gdbserver && \
sudo apt-get install -y gdb

# Make binaries available using path
ENV PATH=$PATH:$PGROOT/bin


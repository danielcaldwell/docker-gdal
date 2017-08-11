FROM geodata/gdal:2.1.3

#RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y \
    wget \
    build-essential \
    gcc \
    checkinstall \
    libreadline-gplv2-dev \
    libncursesw5-dev \
    libssl-dev \
    libsqlite3-dev \
    tk-dev \
    libgdbm-dev \
    libc6-dev \
    libbz2-dev \
    vim

# install latest python
RUN mkdir -p /root/downloads/
WORKDIR /root/downloads
RUN wget https://www.python.org/ftp/python/2.7.13/Python-2.7.13.tgz
RUN tar xzf Python-2.7.13.tgz
WORKDIR /root/downloads/Python-2.7.13
RUN ./configure --with-ensurepip --with-cxx-main=/usr/bin/g++
RUN make
RUN make install

# install AWS libraries
RUN pip install --upgrade awscli
RUN pip install --upgrade requests

WORKDIR /root


FROM ubuntu:16.04

#RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
ENV DEBIAN_FRONTEND noninteractive

ENV GDAL_VERSION 2.1.3
ENV FILEGDBLIB_VERSION 1.5
ENV FILEGDBLIB_FILENAME FileGDB_API_1_5_64gcc51
ENV FILEGDBLIB_DIRNAME FileGDB_API-64gcc51
ENV PROJ4_VERSION 4.9.3
ENV POSTGRES_VERSION 9.5
ENV PYTHON_VERSION 2.7.13

RUN apt-get update && \
    apt-get install -y --fix-missing --no-install-recommends \
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
    vim \
    curl 


# install latest python
RUN mkdir -p /root/downloads/python
WORKDIR /root/downloads/python
RUN wget --no-check-certificate https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
RUN tar xzf Python-${PYTHON_VERSION}.tgz
WORKDIR /root/downloads/python/Python-${PYTHON_VERSION}
RUN ./configure --with-ensurepip --with-cxx-main=/usr/bin/g++
RUN make
RUN make install


# Download and install Proj.4 libraries
RUN mkdir -p /root/downloads/proj4
WORKDIR /root/downloads/proj4

RUN wget http://download.osgeo.org/proj/proj-${PROJ4_VERSION}.tar.gz
RUN tar -xzf proj-${PROJ4_VERSION}.tar.gz

WORKDIR /root/downloads/proj4/proj-${PROJ4_VERSION}
RUN ./configure && make && make install


# Download and install FileGDB libraries
RUN mkdir -p /root/downloads/esri
WORKDIR /root/downloads/esri

RUN wget --no-check-certificate https://github.com/Esri/file-geodatabase-api/raw/master/FileGDB_API_${FILEGDBLIB_VERSION}/${FILEGDBLIB_FILENAME}.tar.gz

RUN tar -xzf ${FILEGDBLIB_FILENAME}.tar.gz

RUN cp -R /root/downloads/esri/${FILEGDBLIB_DIRNAME} /usr/local/FileGDB_API

RUN echo "/usr/local/FileGDB_API/lib" > /etc/ld.so.conf.d/file_gdb_so.conf
RUN ldconfig


RUN mkdir -p /root/downloads/gdal
WORKDIR /root/downloads/gdal

RUN wget http://download.osgeo.org/gdal/${GDAL_VERSION}/gdal-${GDAL_VERSION}.tar.gz
RUN tar -xzf gdal-${GDAL_VERSION}.tar.gz



# Download and install Postgresql Client
RUN groupadd -r postgres --gid=999 && useradd -r -g postgres --uid=999 postgres

RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ jessie-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y  --allow-unauthenticated \
    postgresql-common \
    postgresql-${POSTGRES_VERSION} \
    libpq-dev



# Download and build gdal with filegdb and postgres. 

WORKDIR /root/downloads/gdal/gdal-${GDAL_VERSION}

RUN  ./configure --with-fgdb=/usr/local/FileGDB_API --with-pg=/usr/bin/pg_config

RUN make
RUN make install
RUN ldconfig

# install AWS libraries
RUN pip install --upgrade awscli
RUN pip install --upgrade requests

WORKDIR /root


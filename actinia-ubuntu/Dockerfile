FROM osgeo/grass-gis:current-ubuntu

# based on GRASS GIS releasebranch_8_3 (grass)
# for most recent GRASS GIS, change base image to
# FROM osgeo/grass-gis:main-ubuntu

LABEL authors="Carmen Tawalika,Anika Weinmann,Markus Neteler,Sören Gebbert"
LABEL maintainer="tawalika@mundialis.de,weinmann@mundialis.de,neteler@mundialis.de,soerengebbert@gmail.com"

ENV GDAL_CACHEMAX=2000
ENV GRASS_COMPRESSOR=ZSTD

USER root

# Install dependencies and tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    # gnutls-bin \
    # libgnutls28-dev \
    # ruby \
    build-essential \
    bzip2 \
    curl \
    git \
    language-pack-en-base \
    libcurl4-gnutls-dev \
    libpython3-all-dev \
    moreutils \
    python3 \
    python3-dateutil \
    python3-dev \
    python3-gdal \
    python3-magic \
    python3-pip \
    python3-ply \
    rsync \
    subversion \
    unzip \
    vim \
    wget \
    zip \
    && apt-get autoremove -y \
    && apt-get clean -y

ENV LC_ALL "en_US.UTF-8"
ENV GRASS_SKIP_MAPSET_OWNER_CHECK 1

# Create the database directories
RUN mkdir -p /actinia_core/grassdb && \
    mkdir -p /actinia_core/resources && \
    mkdir -p /actinia_core/workspace/tmp && \
    mkdir -p /actinia_core/workspace/temp_db && \
    mkdir -p /actinia_core/workspace/actinia && \
    mkdir -p /actinia_core/workspace/download_cache && \
    mkdir -p /actinia_core/userdata

# Create generic GRASS GIS binary name regardless of version number
RUN ln -sf `find /usr/local/bin -name "grass??" | sort | tail -n 1` /usr/local/bin/grass
# Create a generic link to GRASS GIS libs (simplifies actinia configuration)
RUN ln -s `grass --config path` /usr/local/grass
# show installed versions
RUN grass --tmp-project EPSG:4326 --exec g.version -rge && \
    pdal --version && \
    python3 --version

# Install selected GRASS GIS addons. Done with -s, so it can be used by actinia
# https://grass.osgeo.org/grass-stable/manuals/g.extension.html
# -s uses $GISBASE instead of $GRASS_ADDON_BASE
WORKDIR /src

# git clone various openEO plugins (local checkout due to non-standard repo structure)
RUN git clone https://github.com/mundialis/openeo-addons.git
RUN git clone https://github.com/NVE/actinia_modules_nve.git /src/nve-addons

# loop over addon list
COPY grass_addons_list.csv /src/grass_addons_list.csv

RUN while IFS=, read -r ADDON SERVER; do if [[ $ADDON != "#*" ]]; then unset URL; test -z $SERVER || URL="url=$SERVER"; grass --tmp-project EPSG:4326 --exec g.extension -s extension=$ADDON $URL;fi;done < /src/grass_addons_list.csv


# install SNAPPY
# SNAP wants the current folder '.' included in LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH ".:$LD_LIBRARY_PATH"
RUN apt-get install default-jdk maven -y
ENV JAVA_HOME "/usr/lib/jvm/java-11-openjdk-amd64"
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
COPY actinia-ubuntu/snap /src/snap
RUN bash /src/snap/install.sh
RUN update-alternatives --remove python /usr/bin/python3

# set link to match actinia default config (needed for tests)
RUN ln -s /actinia_core /root/actinia

# Install actinia-core
RUN git clone https://github.com/actinia-org/actinia-core.git /src/actinia_core
WORKDIR /src/actinia_core
RUN python3 -m pip install --user --upgrade setuptools wheel
RUN python3 setup.py sdist bdist_wheel -d /build
RUN pip3 install /build/*

RUN pip3 install scikit-learn && pip3 install .
## TODO: fix tests
#\
#    && python3 setup.py test

# Install actinia-core plugins
WORKDIR /src
RUN git config --global http.sslVerify false
RUN git clone https://github.com/actinia-org/actinia-statistic-plugin.git /src/actinia_statistic_plugin
WORKDIR /src/actinia_statistic_plugin
RUN pip3 install -r requirements.txt && pip3 install .
## TODO: fix tests
#\
#    && python3 setup.py test

# Reduce the image size
RUN apt-get autoremove -y
RUN apt-get clean -y
RUN rm -rf /src/snap

# Data directory
WORKDIR /grassdb
VOLUME /grassdb

# Copy actinia config file and start scripts
COPY actinia-ubuntu/actinia.cfg /etc/default/actinia
COPY actinia-ubuntu/start.sh /src/start.sh

# Set actinia config file for testing
ENV ACTINIA_CUSTOM_TEST_CFG /etc/default/actinia

ENTRYPOINT ["/bin/bash"]
CMD ["/src/start.sh"]

ENV GISBASE ""

EXPOSE 8088
EXPOSE 9191

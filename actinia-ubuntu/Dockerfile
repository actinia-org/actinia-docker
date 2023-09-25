FROM osgeo/grass-gis:stable-ubuntu as grass

# based on GRASS GIS releasebranch_8_2 (grass)
# for most recent GRASS GIS, change base image to
# FROM osgeo/grass-gis:latest-ubuntu

LABEL authors="Carmen Tawalika,Anika Weinmann,Markus Neteler,Sören Gebbert,Stefan Blumentrath"
LABEL maintainer="tawalika@mundialis.de,weinmann@mundialis.de,neteler@mundialis.de,soerengebbert@gmail.com"

ENV LC_ALL "en_US.UTF-8"
ENV GDAL_CACHEMAX=2000
ENV GRASS_COMPRESSOR=ZSTD
#ENV GRASS_SKIP_MAPSET_OWNER_CHECK 1
#ENV GISBASE ""
ENV ACTINIA_CORE_VERSION=4.10.0

USER root

# Install dependencies and tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends --no-install-suggests \
    build-essential \
    curl \
    git \
    language-pack-en-base \
    libcurl4-gnutls-dev \
    moreutils \
    openjdk-11-jre \
    redis-server \
    redis-tools \
    rsync \
    unzip \
    vim \
    wget \
    zip \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

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

# Install selected GRASS GIS addons. Done with -s, so it can be used by actinia
# https://grass.osgeo.org/grass-stable/manuals/g.extension.html
# -s uses $GISBASE instead of $GRASS_ADDON_BASE

FROM grass as build

WORKDIR /src
# loop over addon list
COPY grass_addons_list.csv /src/grass_addons_list.csv

# git clone various openEO plugins (local checkout due to non-standard repo structure)
RUN git clone https://github.com/mundialis/openeo-addons.git \
    && mkdir /src/grass_addons \
    # python3 -m pip install --no-cache-dir GDAL==$(gdal-config --version) && \
    && while IFS=, read -r ADDON SERVER; do unset URL; test -z $SERVER || URL="url=$SERVER"; grass --tmp-location EPSG:4326 --exec g.extension prefix=/src/grass_addons extension=$ADDON $URL;done < /src/grass_addons_list.csv && \
    rm -r openeo-addons

# Install SNAP and SNAPPY
# SNAP wants the current folder '.' included in LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH ".:$LD_LIBRARY_PATH"
RUN apt-get update \
    && apt-get install -y  --no-install-recommends --no-install-suggests \
    default-jdk \
    maven \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME "/usr/lib/jvm/java-11-openjdk-amd64"
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
COPY actinia-ubuntu/snap_* /src/
RUN bash /src/snap_install.sh
#RUN update-alternatives --remove python /usr/bin/python3

# set link to match actinia default config (needed for tests)
RUN ln -s /actinia_core /root/actinia

COPY actinia-ubuntu/requirements_ubuntu22.txt requirements_ubuntu22.txt

RUN mkdir /src/site-packages \
    && mkdir /src/pip_cache \
    && wget https://raw.githubusercontent.com/actinia-org/actinia_core/${ACTINIA_CORE_VERSION}/requirements.txt \
    && sed -i 's/==/>=/' requirements.txt \
    && python3 -m pip install \
       --cache-dir /src/pip_cache \
       -r requirements.txt \
     && python3 -m pip install \
       --cache-dir /src/pip_cache \
       -r requirements.txt \
       -r requirements_ubuntu22.txt


RUN mkdir /src/build && \
    PLUGIN_VERSION=0.2.1; WHEEL_NAME=actinia_statistic_plugin-${PLUGIN_VERSION}-py2.py3-none-any.whl; \
    curl -L --output /src/build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia_statistic_plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME} && \
    PLUGIN_VERSION=0.1.0; WHEEL_NAME=actinia_satellite_plugin-${PLUGIN_VERSION}-py2.py3-none-any.whl; \
    curl -L --output /src/build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia_satellite_plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME} && \
    PLUGIN_VERSION=1.0.2; WHEEL_NAME=actinia_metadata_plugin.wsgi-${PLUGIN_VERSION}-py2.py3-none-any.whl; \
    curl -L --output /src/build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-metadata-plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME} && \
    PLUGIN_VERSION=2.5.0; WHEEL_NAME=actinia_module_plugin.wsgi-${PLUGIN_VERSION}-py2.py3-none-any.whl; \
    curl -L --output /src/build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-module-plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME} && \
    PLUGIN_VERSION=0.1.1; WHEEL_NAME=actinia_stac_plugin.wsgi-${PLUGIN_VERSION}-py2.py3-none-any.whl; \
    curl -L --output /src/build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-stac-plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME} && \
    PLUGIN_VERSION=1.0.0; WHEEL_NAME=actinia_tiling_plugin.wsgi-${PLUGIN_VERSION}-py2.py3-none-any.whl; \
    curl -L --output /src/build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-tiling-plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME} && \
    ACTINIA_API_VERSION=3.4.0; WHEEL_NAME=actinia_api-${ACTINIA_API_VERSION}-py3-none-any.whl; \
    curl -L --output /src/build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-api/releases/download/${ACTINIA_API_VERSION}/${WHEEL_NAME} && \
    WHEEL_NAME=actinia_core-${ACTINIA_CORE_VERSION}-py3-none-any.whl; \
    curl -L --output /src/build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-core/releases/download/${ACTINIA_CORE_VERSION}/${WHEEL_NAME} && \
    for i in /src/build/*; do python3 -m pip install \
        --cache-dir /src/pip_cache \
        # Dependencies should have been included in the requirements
        --no-deps \
        $i; done && \
    rm -r /src/build

RUN python3 -m pip install \
    --cache-dir /src/pip_cache \
    Cython cython-setuptools setuptools_cython

FROM grass as actinia

COPY --from=build /usr/local/snap /usr/local/snap
COPY --from=build /src/grass_addons /usr/local/grass
COPY --from=build /root/.snap /root/.snap
COPY --from=build /usr/local/lib/python3.10/ /usr/local/lib/python3.10/

# Data directory
WORKDIR /grassdb
VOLUME /grassdb

# Copy actinia config file and start scripts
COPY actinia-ubuntu/actinia.cfg /etc/default/actinia
COPY actinia-ubuntu/start.sh /src/start.sh

ENV PATH=${PATH}:/usr/local/snap/bin

# Set actinia config file for testing
ENV ACTINIA_CUSTOM_TEST_CFG /etc/default/actinia

# ENTRYPOINT ["/bin/bash"]
CMD ["/src/start.sh"]

EXPOSE 8088
EXPOSE 9191

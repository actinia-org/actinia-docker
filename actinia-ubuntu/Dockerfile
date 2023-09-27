ARG GRASS_VERSION=current
# current = GRASS GIS docker image from latest release branch
# for development verions use "main" or "releasebranch_8_2" for a specific GRASS GIS version

FROM osgeo/grass-gis:${GRASS_VERSION}-ubuntu as grass

LABEL authors="Carmen Tawalika,Anika Weinmann,Markus Neteler,Sören Gebbert,Stefan Blumentrath"
LABEL maintainer="tawalika@mundialis.de,weinmann@mundialis.de,neteler@mundialis.de,soerengebbert@gmail.com"

ENV LC_ALL "en_US.UTF-8"
ENV GDAL_CACHEMAX=2000
ENV GRASS_COMPRESSOR=ZSTD
#ENV GRASS_SKIP_MAPSET_OWNER_CHECK 1
#ENV GISBASE ""

ARG JAVA_VERSION=11
ARG PYTHON_VERSION=3.10

ENV ACTINIA_CORE_VERSION=4.10.0
ENV PATH=${PATH}:/usr/local/snap/bin
ENV SNAP_HOME=/usr/local/snap
ENV JAVA_HOME "/usr/lib/jvm/java-${JAVA_VERSION}-openjdk-amd64"

# SNAP wants the current folder '.' included in LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH ".:$LD_LIBRARY_PATH"

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
    openjdk-${JAVA_VERSION}-jre \
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

FROM grass as addons

WORKDIR /src
# loop over addon list
COPY grass_addons_list.csv /src/grass_addons_list.csv

# git clone various openEO plugins (local checkout due to non-standard repo structure)
RUN git clone https://github.com/mundialis/openeo-addons.git \
    && mkdir /src/grass_addons \
    # python3 -m pip install --no-cache-dir GDAL==$(gdal-config --version) && \
    && while IFS=, read -r ADDON SERVER; do unset URL; test -z $SERVER || URL="url=$SERVER"; grass --tmp-location EPSG:4326 --exec g.extension prefix=/src/grass_addons extension=$ADDON $URL;done < /src/grass_addons_list.csv && \
    rm -r openeo-addons

FROM grass as snap

# Install SNAP and SNAPPY
RUN apt-get update \
    && apt-get install -y  --no-install-recommends --no-install-suggests \
    openjdk-${JAVA_VERSION}-jdk \
    maven \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

#RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 1
COPY actinia-ubuntu/snap /src/snap

RUN bash /src/snap/install.sh
#RUN update-alternatives --remove python /usr/bin/python3
#RUN /usr/bin/python3 ./snappyutil.py --snap_home /usr/local/snap --java_module /usr/local/snap/snap/modules/org-esa-snap-snap-python.jar --force --log_file ./snappyutil.log --jvm_max_mem 88G --java_home /usr/lib/jvm/java-11-openjdk-amd64 --req_arch amd64
#RUN cat /root/.snap/snap-python/snappy/snappyutil.log
#RUN /usr/local/snap/bin/snappy-conf /usr/bin/python3 || cat /root/.snap/snap-python/snappy/snappyutil.log
#RUN /usr/local/snap/bin/snap --nosplash --nogui --modules --update-all

FROM grass as actinia_python

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
       -r requirements_ubuntu22.txt \
    && rm -rf /tmp/pip-*

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

FROM grass as actinia

COPY --link --from=snap /usr/local/snap /usr/local/snap
COPY --link --from=snap /root/.snap /root/.snap

COPY --link --from=addons /src/grass_addons /usr/local/grass

COPY --link --from=actinia_python /usr/local/lib/python${PYTHON_VERSION}/ /usr/local/lib/python${PYTHON_VERSION}/
COPY --link --from=actinia_python /usr/local/bin/ /usr/local/bin

RUN python3 -m pip install \
    --no-cache-dir \
    Cython cython-setuptools setuptools_cython

# Data directory
WORKDIR /grassdb
VOLUME /grassdb

# Copy actinia config file and start scripts
COPY actinia-ubuntu/actinia.cfg /etc/default/actinia
COPY actinia-ubuntu/start.sh /src/start.sh
RUN chmod ugo+x /src/start.sh

# Set actinia config file for testing
ENV ACTINIA_CUSTOM_TEST_CFG /etc/default/actinia

# ENTRYPOINT ["/bin/bash", "-c", "$@"]
CMD ["/src/start.sh"]

EXPOSE 8088
EXPOSE 9191

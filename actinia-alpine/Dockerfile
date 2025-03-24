FROM alpine:3.20 as version
RUN apk add git

COPY .git /src/actinia-docker/.git
WORKDIR /src/actinia-docker
RUN git describe --dirty --tags --long --first-parent > /actinia-docker-version.txt

FROM mundialis/actinia:alpine-dependencies-2024-07-02 as base
FROM osgeo/grass-gis:releasebranch_8_4-alpine as grass
FROM mundialis/esa-snap:s1tbx-543d1be as snap

FROM base

LABEL authors="Carmen Tawalika,Anika Bettge,Markus Neteler,Sören Gebbert"
LABEL maintainer="tawalika@mundialis.de,weinmann@mundialis.de,neteler@mundialis.de"

ENV LC_ALL "en_US.UTF-8"
ENV GDAL_CACHEMAX=2000
ENV GRASS_COMPRESSOR=ZSTD
ENV GRASS_SKIP_MAPSET_OWNER_CHECK 1
ENV GISBASE ""
ENV ACTINIA_CORE_VERSION=5.0.0

USER root

# Set actinia-docker version
COPY --from=version /actinia-docker-version.txt /

# # ESA SNAP SETUP
# ENV LD_LIBRARY_PATH ".:$LD_LIBRARY_PATH"
# COPY --from=snap /root/.snap /root/.snap
# COPY --from=snap /usr/local/snap /usr/local/snap
# # using gpt (graph processing tool) instead:
# # add gpt to PATH
# ENV PATH="${PATH}:/usr/local/snap/bin"
# # test gpt
# RUN gpt -h

# GRASS GIS SETUP
COPY --from=grass /usr/local/bin/grass /usr/local/bin/grass
COPY --from=grass /usr/local/grass* /usr/local/grass/
# COPY --from=grass /usr/lib/gdalplugins/*_GRASS* /usr/lib/gdalplugins/
COPY --from=grass /usr/local/grass/etc/proj/ /etc/proj/
COPY --from=grass /usr/local/grass/etc/colors/ /etc/colors/
RUN pip3 install --upgrade pip six grass-session --ignore-installed six
RUN ln -s /usr/local/grass `grass --config path`
RUN grass --tmp-project EPSG:4326 --exec g.version -rge && \
    pdal --version && \
    python3 --version

# GRASS GIS addons installation
# git clone various openEO plugins (local checkout due to non-standard repo structure)
RUN git clone https://github.com/mundialis/openeo-addons.git /src/openeo-addons
RUN git clone https://github.com/NVE/actinia_modules_nve.git /src/nve-addons

# TODO: Fix requirements installation for openeo-udf, needed by t.rast.udf.
# RUN git clone https://github.com/Open-EO/openeo-udf.git /src/openeo-udf
# WORKDIR /src/openeo-udf
# RUN pip3 install -r requirements.txt && python3 setup.py install

COPY grass_addons_list.csv /src/grass_addons_list.csv

RUN while IFS=, read -r ADDON SERVER; do if [[ $ADDON != "#*" ]]; then unset URL; test -z $SERVER || URL="url=$SERVER"; grass --tmp-project EPSG:4326 --exec g.extension -s extension=$ADDON $URL;fi;done < /src/grass_addons_list.csv

# actinia-core and plugins installation
WORKDIR /build

ARG PLUGIN_VERSION=0.2.2
ARG WHEEL_NAME=actinia_statistic_plugin-${PLUGIN_VERSION}-py2.py3-none-any.whl
RUN curl -L --output /build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia_statistic_plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME}

ARG PLUGIN_VERSION=0.1.2
ARG WHEEL_NAME=actinia_satellite_plugin-${PLUGIN_VERSION}-py2.py3-none-any.whl
RUN curl -L --output /build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia_satellite_plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME}

ARG PLUGIN_VERSION=1.0.3
ARG WHEEL_NAME=actinia_metadata_plugin.wsgi-${PLUGIN_VERSION}-py2.py3-none-any.whl
RUN curl -L --output /build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-metadata-plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME}

ARG PLUGIN_VERSION=2.7.0
ARG WHEEL_NAME=actinia_module_plugin-${PLUGIN_VERSION}-py3-none-any.whl
RUN curl -L --output /build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-module-plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME}

ARG PLUGIN_VERSION=0.2.1
ARG WHEEL_NAME=actinia_stac_plugin.wsgi-${PLUGIN_VERSION}-py2.py3-none-any.whl
RUN curl -L --output /build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-stac-plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME}

ARG PLUGIN_VERSION=1.0.2
ARG WHEEL_NAME=actinia_tiling_plugin.wsgi-${PLUGIN_VERSION}-py2.py3-none-any.whl
RUN curl -L --output /build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-tiling-plugin/releases/download/${PLUGIN_VERSION}/${WHEEL_NAME}

ENV ACTINIA_API_VERSION=3.6.0
ARG WHEEL_NAME=actinia_api-${ACTINIA_API_VERSION}-py3-none-any.whl
RUN curl -L --output /build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-api/releases/download/${ACTINIA_API_VERSION}/${WHEEL_NAME}

ARG WHEEL_NAME=actinia_core-${ACTINIA_CORE_VERSION}-py3-none-any.whl
RUN curl -L --output /build/${WHEEL_NAME} \
    https://github.com/actinia-org/actinia-core/releases/download/${ACTINIA_CORE_VERSION}/${WHEEL_NAME}

# Install actinia-core and plugins
# Difference to `pip3 install /build/*`: Loop uses already installed
# dependencies while installing in bulk will update dependencies, even
# though older ones are already installed.
RUN for i in /build/*; do pip3 install $i; done

# Copy actinia config file and start scripts + set needed envs
COPY actinia-alpine/actinia.cfg /etc/default/actinia
COPY actinia-alpine/start.sh /src/start.sh

# Create the database directories
RUN mkdir -p /actinia_core/grassdb && \
    mkdir -p /actinia_core/resources && \
    mkdir -p /actinia_core/workspace/tmp && \
    mkdir -p /actinia_core/workspace/temp_db && \
    mkdir -p /actinia_core/workspace/actinia && \
    mkdir -p /actinia_core/workspace/download_cache && \
    mkdir -p /actinia_core/userdata && \
    ln -s /actinia_core /root/actinia

VOLUME /grassdb
WORKDIR /src/actinia_core

# install GDAL GRASS plugin (required for i.sentinel1.pyrosargeocode)
RUN apk add cmake
RUN mkdir -p /usr/lib/gdalplugins
RUN git clone https://github.com/OSGeo/gdal-grass.git
RUN cd gdal-grass \
&& cmake -B build -DAUTOLOAD_DIR=/usr/lib/gdalplugins -DBUILD_TESTING=OFF \
&& cmake --build build \
&& cmake --install build
RUN cd .. && rm -rf gdal-grass

ENTRYPOINT ["/bin/sh"]
CMD ["/src/start.sh"]

EXPOSE 8088
EXPOSE 9191

# syntax=docker/dockerfile:1.19@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6

# based on GRASS releasebranch_8_4 (grass)
# for most recent GRASS, change branch to main

ARG BRANCH=releasebranch_8_4

FROM osgeo/grass-gis:${BRANCH}-ubuntu AS version_info
COPY .git /src/actinia-docker/.git
WORKDIR /src/actinia-docker
RUN git describe --dirty --tags --always --long --first-parent > /actinia-docker-version.txt


# FROM osgeo/grass-gis:${BRANCH}-ubuntu AS grass
FROM osgeo/grass-gis:${BRANCH}-ubuntu AS grass

# FROM osgeo/grass-gis:latest-ubuntu

ENV GDAL_CACHEMAX=2000 \
    GRASS_COMPRESSOR=ZSTD \
    GISBASE="" \
    ESA_SNAP_VERSION=13 \
    ACTINIA_CORE_VERSION=7.0.1

USER root

# Install dependencies (JRE headless with recomended packages) and tools
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-suggests \
    default-jre-headless \
    rsync \
    && apt-get autoremove -y \
    && apt-get clean all \
    && rm -rf /var/lib/apt/lists/* \
    # Create the database directories
    && mkdir -p /actinia_core/grassdb \
    && mkdir -p /actinia_core/resources \
    && mkdir -p /actinia_core/workspace/tmp \
    && mkdir -p /actinia_core/workspace/temp_db \
    && mkdir -p /actinia_core/workspace/actinia \
    && mkdir -p /actinia_core/workspace/download_cache \
    && mkdir -p /actinia_core/userdata

# Create generic GRASS binary name regardless of version number and
# Create a generic link to GRASS libs (simplifies actinia configuration)
RUN ln -s "$(grass --config path)" /usr/local/grass

FROM grass AS addons
# show installed versions
RUN grass --tmp-project EPSG:4326 --exec g.version -rge && \
    pdal --version && \
    python3 --version

# Install selected GRASS addons
WORKDIR /src

# Get addon list and install script
COPY grass_addons_list.csv /src/grass_addons_list.csv
COPY install_addons.sh /src/install_addons.sh

# git clone various openEO plugins
# use local checkout due to non-standard repo structure and for performance
# ToDo: consider pinning AddOns with commit-hash or tag
RUN mkdir /src/grass_addons && \
    mkdir /src/grass_addons_build && \
    git clone --depth=1 https://github.com/osgeo/grass-addons.git && \
    git clone --depth=1 https://github.com/mundialis/openeo-addons.git && \
    git clone --depth=1 https://github.com/NVE/actinia_modules_nve.git /src/nve-addons && \
    bash install_addons.sh /src/grass_addons_list.csv && \
    rm -r openeo-addons && \
    rm -r grass-addons && \
    rm -r nve-addons

FROM grass AS esa_snap
# Set JAVA _HOME
ENV JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"

WORKDIR /src

# SNAP wants the current folder '.' included in LD_LIBRARY_PATH
ENV LD_LIBRARY_PATH=".:$LD_LIBRARY_PATH"
# Install JRE (with recomended packages and maven as build tool for SNAP
RUN apt-get update -y \
    && apt-get install -y --no-install-suggests \
    default-jdk-headless \
    maven && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    # Create SNAP install directory
    mkdir -p /src/snap

COPY actinia-ubuntu/snap/response.varfile ./snap/
# hadolint ignore=SC2016
RUN wget -q -O /src/snap/esa-snap_all_linux-${ESA_SNAP_VERSION}.0.0.sh \
	  "https://download.esa.int/step/snap/${ESA_SNAP_VERSION}.0/installers/esa-snap_all_linux-${ESA_SNAP_VERSION}.0.0.sh" \
    && sh /src/snap/esa-snap_all_linux-${ESA_SNAP_VERSION}.0.0.sh -q -varfile /src/snap/response.varfile \
    && sed -i 's+jdkhome="./jre"+jdkhome="$JAVA_HOME"+g' /usr/local/esa-snap/etc/snap.conf \
    && /usr/local/esa-snap/bin/snap --nosplash --nogui --modules --update-all \
    && rm -rf /usr/local/esa-snap/*/update/backup/* \
    && rm -rf /usr/local/esa-snap/jre \
    && rm -rf /src/snap

FROM grass AS actinia

# Set actinia-docker version
COPY --link --from=version_info /actinia-docker-version.txt /

# Get build addons
COPY --link --from=addons /src/grass_addons_build /usr/local/grass

# Get ESA SNAP
COPY --link --from=esa_snap /root/.snap /root/
COPY --link --from=esa_snap /usr/local/snap /usr/local/snap


# Add ESA SNAP to PATH, point to system Java JRE in snap.conf
# and point to actinia config file for testing
ENV JAVA_HOME="/usr/lib/jvm/java-21-openjre-amd64" \
    PATH="/usr/local/esa-snap/bin:${PATH}" \
    ACTINIA_CUSTOM_TEST_CFG=/etc/default/actinia

# Set link to match actinia default config (needed for tests)
RUN ln -s /actinia_core /root/actinia

# Install actinia-core and plugins with dependencies
WORKDIR /build
ARG EXAMPLE_PLUGIN_VERSION=1.1.0
# Install actinia-core and plugins
RUN echo "Install Python" \
    && wget --progress="dot:giga" -q https://bootstrap.pypa.io/pip/get-pip.py \
    && python3 get-pip.py --no-cache-dir --break-system-packages \
    && rm -r get-pip.py \
    && python3 -m pip install --no-cache-dir --break-system-packages \
    actinia-api==3.8.0 \
    actinia-core==${ACTINIA_CORE_VERSION} \
    actinia-grassdata-management-plugin==1.0.0 \
    actinia-metadata-plugin==1.0.4 \
    actinia-module-plugin==2.9.0 \
    actinia-parallel-plugin==1.2.0 \
    actinia-satellite-plugin==0.3.0 \
    actinia-stac-plugin==0.4.0 \
    actinia-statistic-plugin==0.4.0 \
    actinia-tiling-plugin==1.2.0 \
    # Install example plugin (not on PyPI)
    https://github.com/actinia-org/actinia-example-plugin/releases/download/${EXAMPLE_PLUGIN_VERSION}/actinia_example_plugin-${EXAMPLE_PLUGIN_VERSION}-py3-none-any.whl

# Copy actinia config file and start scripts + set needed envs
COPY actinia-alpine/actinia.cfg /etc/default/actinia
COPY actinia-alpine/start.sh /src/start.sh

# Set with "$(git log -n 1 --pretty=format:'%h')"
ARG REVISION=latest
# Set with "$(date +'%Y-%m-%dT%H:%M:%S%:z')"
ARG BUILD_DATE
ARG BRANCH
ARG TITLE="actinia ${ACTINIA_CORE_VERSION}"
ARG URL="https://github.com/actinia-org/actinia-docker/blob/main/actinia-ubuntu/Dockerfile"
ARG DOCUMENTATION="https://github.com/actinia-org/actinia-docker/tree/main/actinia-ubuntu/README.md"
ARG SOURCE="https://github.com/actinia-org/actinia-docker/tree/main/actinia-ubuntu"
ARG AUTHORS="Carmen Tawalika,Anika Weinmann,Markus Neteler,Sören Gebbert,Stefan Blumentrath"
ARG MAINTAINERS="tawalika@mundialis.de,weinmann@mundialis.de,neteler@mundialis.de,soerengebbert@gmail.com"
ARG VENDOR="Actinia org (https://actinia.org) and GRASS Development Team (https://grass.osgeo.org)"
ARG LICENSE="GPL-2.0-or-later"
ARG BASE_NAME="osgeo/grass-gis:${BRANCH}-ubuntu"
ARG DESCRIPTION="actinia - The geoprocessing platform actinia analyses large volumes of Earth-observation and geodata in the cloud "
ARG DESCRIPTION="$DESCRIPTION (https://github.com/actinia-org)."
ARG DESCRIPTION="$DESCRIPTION Build with:"
ARG DESCRIPTION="$DESCRIPTION GRASS ${BRANCH},"
ARG DESCRIPTION="$DESCRIPTION ESA SNAP ${ESA_SNAP_VERSION}"
ARG REF_NAME="actinia"

# Add OCI annotations (see: https://github.com/opencontainers/image-spec/blob/main/annotations.md)
LABEL org.opencontainers.image.authors="$AUTHORS" \
      org.opencontainers.image.vendor="$VENDOR" \
      org.opencontainers.image.licenses="$LICENSE" \
      org.opencontainers.image.created="$BUILD_DATE" \
      org.opencontainers.image.revision="$REVISION" \
      org.opencontainers.image.url="$URL" \
      org.opencontainers.image.source="$SOURCE" \
      org.opencontainers.image.version="$ACTINIA_CORE_VERSION" \
      org.opencontainers.image.title="$TITLE" \
      org.opencontainers.image.description="$DESCRIPTION" \
      org.opencontainers.image.base.name="$BASE_NAME" \
      org.opencontainers.image.ref.name="$REF_NAME" \
      org.opencontainers.image.documentation="$DOCUMENTATION" \
      maintainers="$MAINTAINERS"

# Data directory
WORKDIR /grassdb
VOLUME /grassdb

# Test SNAP GPT
RUN gpt -h

# Test addon installation
RUN grass --tmp-project EPSG:4326 --exec i.sentinel1.pyrosargeocode --h
RUN grass --tmp-project EPSG:4326 --exec v.in.geojson --h
RUN grass --tmp-project EPSG:4326 --exec r.hants --h

ENTRYPOINT ["/bin/bash"]
CMD ["/src/start.sh"]

ENV GISBASE=""

EXPOSE 8088
EXPOSE 9191

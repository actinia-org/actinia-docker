FROM mundialis/actinia:2.11.1
# FROM mundialis/actinia:latest

# # Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1
# # Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=actinia_core.main
ENV FLASK_ENV=development
ENV FLASK_DEBUG=1
ENV DEFAULT_CONFIG_PATH=/etc/default/actinia

RUN pip3 uninstall actinia-core -y
RUN pip3 uninstall actinia_core -y

COPY actinia-dev/actinia.cfg /etc/default/actinia
COPY actinia-dev/keycloak.json /etc/default/keycloak.json
COPY actinia-dev/interim_endpoints.csv /etc/default/actinia_interim_endpoints.csv

WORKDIR /src
# Even though the code is mounted later, it needs to be installed once
RUN rm -rf /src/actinia_core
RUN git clone https://github.com/actinia-org/actinia-core.git /src/actinia_core

RUN git config --global --add safe.directory /src/actinia*

WORKDIR /src/actinia_core/
RUN pip3 install -e .

# RUN pip3 uninstall actinia_example_plugin.wsgi -y
# RUN git clone https://github.com/actinia-org/actinia-example-plugin.git /src/actinia-example-plugin
# WORKDIR /src/actinia-example-plugin/
# RUN pip3 install -e .

# for actinia plugin development, incomment matching block

# RUN pip3 uninstall actinia_metadata_plugin.wsgi -y
# RUN git clone https://github.com/actinia-org/actinia-metadata-plugin.git /src/actinia-metadata-plugin
# WORKDIR /src/actinia-metadata-plugin/
# RUN pip3 install -e .

# RUN pip3 uninstall actinia_module_plugin.wsgi -y
# RUN git clone https://github.com/actinia-org/actinia-module-plugin.git /src/actinia-module-plugin
# WORKDIR /src/actinia-module-plugin/
# RUN pip3 install -e .

# RUN pip3 uninstall actinia_parallel_plugin -y
# RUN git clone https://github.com/actinia-org/actinia-parallel-plugin.git /src/actinia_parallel_plugin
# WORKDIR /src/actinia_parallel_plugin/
# RUN pip3 install -e .

# RUN pip3 uninstall actinia_satellite_plugin -y
# RUN git clone https://github.com/actinia-org/actinia-satellite-plugin.git /src/actinia_satellite_plugin
# WORKDIR /src/actinia_satellite_plugin/
# RUN pip3 install -e .

# RUN pip3 uninstall actinia_stac_plugin.wsgi -y
# RUN git clone https://github.com/actinia-org/actinia-stac-plugin.git /src/actinia-stac-plugin
# WORKDIR /src/actinia-stac-plugin/
# RUN pip3 install -e .

# RUN pip3 uninstall actinia_statistic_plugin -y
# RUN git clone https://github.com/actinia-org/actinia-statistic-plugin.git /src/actinia_statistic_plugin
# WORKDIR /src/actinia_statistic_plugin/
# RUN pip3 install -e .

# RUN pip3 uninstall actinia_tiling_plugin -y
# RUN git clone https://github.com/actinia-org/actinia-tiling-plugin.git /src/actinia_tiling_plugin
# WORKDIR /src/actinia_tiling_plugin/
# RUN pip3 install -e .

# RUN pip3 uninstall actinia_api -y
# RUN git clone https://github.com/actinia-org/actinia-api.git /src/actinia-api
# WORKDIR /src/actinia-api/
# RUN pip3 install -e .

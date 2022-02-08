# FROM mundialis/actinia-core:g80-latest-alpine
FROM actinia:alpine

# # Keeps Python from generating .pyc files in the container
ENV PYTHONDONTWRITEBYTECODE=1
# # Turns off buffering for easier container logging
ENV PYTHONUNBUFFERED=1
ENV FLASK_APP=actinia_core.main
ENV FLASK_ENV=development
ENV FLASK_DEBUG=1
ENV DEFAULT_CONFIG_PATH=/etc/default/actinia

RUN pip3 uninstall actinia-core -y

COPY actinia-dev/actinia.cfg /etc/default/actinia

# Even though the code is mounted, it need to be installed once
RUN rm -rf /src/actinia_core
RUN git clone https://github.com/mundialis/actinia_core.git /src/actinia_core

WORKDIR /src/actinia_core/
RUN pip3 install -e .

# for actinia plugin development, add e.g.
# RUN pip3 uninstall actinia-module-plugin.wsgi -y
# WORKDIR /src/actinia-module-plugin

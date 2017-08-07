FROM bossjones/boss-docker-python3:latest
MAINTAINER Malcolm Jones <bossjones@theblacktonystark.com>

ARG ARG_DEVPI_CLIENT_VERSION
ARG ARG_DEVPI_SERVER_VERSION
ARG ARG_DEVPI_WEB_VERSION
ARG BUILD_DATE
ARG CONTAINER_VERSION
ARG GIT_BRANCH
ARG GIT_SHA

ENV DEVPI_SERVER_VERSION $ARG_DEVPI_SERVER_VERSION
ENV DEVPI_WEB_VERSION $ARG_DEVPI_WEB_VERSION
ENV DEVPI_CLIENT_VERSION $ARG_DEVPI_CLIENT_VERSION
ENV PIP_NO_CACHE_DIR="off"
ENV PIP_INDEX_URL="https://pypi.python.org/simple"
ENV PIP_TRUSTED_HOST="127.0.0.1"
ENV VIRTUAL_ENV /env
ENV BUILD_DATE $BUILD_DATE
ENV CONTAINER_VERSION $CONTAINER_VERSION
ENV GIT_BRANCH $GIT_BRANCH
ENV GIT_SHA $GIT_SHA

# devpi user
RUN set -xe \
    && useradd -U -d /data -m -r -G tty devpi \
    && usermod -a -G devpi -s /sbin/nologin -u 1000 devpi \
    && groupmod -g 1000 devpi

# create a virtual env in $VIRTUAL_ENV, ensure it respects pip version
RUN pip install virtualenv \
    && virtualenv $VIRTUAL_ENV \
    && $VIRTUAL_ENV/bin/pip install pip==$PYTHON_PIP_VERSION
ENV PATH $VIRTUAL_ENV/bin:$PATH

RUN pip install \
    "devpi-client==${DEVPI_CLIENT_VERSION}" \
    "devpi-web==${DEVPI_WEB_VERSION}" \
    "devpi-server==${DEVPI_SERVER_VERSION}"

EXPOSE 3141
# VOLUME /data

COPY docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

USER devpi
ENV HOME /data
WORKDIR /data

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["devpi"]



# -----

# FROM bossjones/boss-docker-python3:latest
# MAINTAINER Malcolm Jones <bossjones@theblacktonystark.com>



# # Prepare packaging environment
# ENV DEBIAN_FRONTEND noninteractive

# # metadata
# ARG CONTAINER_VERSION
# ARG GIT_BRANCH
# ARG GIT_SHA
# ARG BUILD_DATE
# ARG ARG_DEVPI_SERVER_VERSION
# ARG ARG_DEVPI_WEB_VERSION
# ARG ARG_DEVPI_CLIENT_VERSION

# # Build-time metadata as defined at http://label-schema.org
# LABEL \
#   org.label-schema.name="scarlett-devpi-docker" \
#   org.label-schema.description="pypi caching service using devpi and docker" \
#   org.label-schema.url="https://github.com/bossjones/scarlett-devpi-docker/" \
#   org.label-schema.vcs-ref=${GIT_SHA:-''} \
#   org.label-schema.vcs-url="https://github.com/bossjones/scarlett-devpi-docker" \
#   org.label-schema.vendor="Tonydark Labs" \
#   org.label-schema.version=${CONTAINER_VERSION:-''} \
#   org.label-schema.schema-version="1.0" \
#   org.label-schema.build-date=${BUILD_DATE:-''}


# ENV DEVPI_SERVER_VERSION $ARG_DEVPI_SERVER_VERSION
# ENV DEVPI_WEB_VERSION $ARG_DEVPI_WEB_VERSION
# ENV DEVPI_CLIENT_VERSION $ARG_DEVPI_CLIENT_VERSION
# ENV PIP_NO_CACHE_DIR="off"
# ENV PIP_INDEX_URL="https://pypi.python.org/simple"
# ENV PIP_TRUSTED_HOST="127.0.0.1"
# ENV VIRTUAL_ENV /env


# RUN pip install "devpi-server>=2.5,<2.6dev" "devpi-client>=2.3,<=2.4dev"
# VOLUME /mnt
# EXPOSE 3141
# ADD run.sh /
# CMD ["/run.sh"]

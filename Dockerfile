ARG PYTHON_IMAGE=python:3.14-alpine

FROM ${PYTHON_IMAGE} AS build

RUN apk add --no-cache git

COPY requirements.lock /requirements.lock
RUN pip install --no-cache-dir \
    --prefix=/install \
    -r /requirements.lock

WORKDIR /source
ARG SYNCPLAY_SHA
RUN git init . && \
    git remote add origin https://github.com/Syncplay/syncplay.git && \
    git fetch --depth=1 origin "${SYNCPLAY_SHA}" && \
    git checkout FETCH_HEAD && \
    rm -rf .git

FROM ${PYTHON_IMAGE}

COPY entrypoint.sh /entrypoint.sh
COPY health.py /health.py

RUN chmod +x /entrypoint.sh && \
    mkdir -p /var/lib/syncplay 

COPY --from=build /install /usr/local
COPY --from=build /source /opt/syncplay

EXPOSE 8999

HEALTHCHECK \
    --interval=30s \
    --timeout=5s \
    --start-period=10s \
    --retries=3 \
    CMD ["python", "/health.py"]

ARG SYNCPLAY_SHA
ARG BUILD_SHA
LABEL \
    org.opencontainers.image.source="https://github.com/Q16KBreak/syncplay" \
    org.opencontainers.image.revision="${SYNCPLAY_SHA}-${BUILD_SHA}"

ENTRYPOINT ["/entrypoint.sh"]
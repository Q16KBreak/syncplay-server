FROM python:3.14-alpine@sha256:a18b20ad69e74df6cf6d2e1b1a260d7a1ecf5380fd83b310f83ba88c461cf894 AS python-base

FROM python-base AS build

RUN apk add --no-cache git

WORKDIR /source
ARG SYNCPLAY_SHA
RUN git init . && \
    git remote add origin https://github.com/Syncplay/syncplay.git && \
    git fetch --depth=1 origin "${SYNCPLAY_SHA}" && \
    git checkout FETCH_HEAD && \
    rm -rf .git

COPY requirements.txt /requirements.txt
RUN pip install --no-cache-dir \
    --prefix=/install \
    -r /requirements.txt

FROM python-base

COPY entrypoint.sh /entrypoint.sh
COPY health.py /health.py

RUN chmod +x /entrypoint.sh && \
    mkdir -p /var/lib/syncplay 

COPY --from=build /source /opt/syncplay
COPY --from=build /install /usr/local

EXPOSE 8999

# HEALTHCHECK \
#     --interval=30s \
#     --timeout=5s \
#     --start-period=10s \
#     --retries=3 \
#     CMD ["python", "/health.py"]

ARG SYNCPLAY_SHA
ARG BUILD_SHA
LABEL \
    org.opencontainers.image.source="https://github.com/Q16KBreak/syncplay" \
    org.opencontainers.image.revision="${SYNCPLAY_SHA}-${BUILD_SHA}"

ENTRYPOINT ["/entrypoint.sh"]
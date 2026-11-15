FROM python:3.15-alpine@sha256:0f9552bb28711333da16915ec146f5e6bb44a7fdac9ced15dc17c2e0206346dd AS python-base

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
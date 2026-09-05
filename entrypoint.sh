#!/bin/sh
set -eu

main() {
    set -- "$@"

    if [ -z "${SYNCPLAY_SALT:-}" ]; then
        SALT_FILE=/var/lib/syncplay/salt

        if [ -f "$SALT_FILE" ]; then
            SYNCPLAY_SALT="$(cat "$SALT_FILE")"
        else
            SYNCPLAY_SALT="$(od -An -N16 -tx1 /dev/urandom | tr -d ' \n')"
            printf '%s\n' "$SYNCPLAY_SALT" > "$SALT_FILE"
        fi
    fi

    set -- "--salt=${SYNCPLAY_SALT}" "$@"

    if [ -n "${SYNCPLAY_PORT:-}" ]; then
        set -- "--port=${SYNCPLAY_PORT}" "$@"
    fi

    if [ "${SYNCPLAY_ISOLATE_ROOMS:-false}" = "true" ]; then
        set -- "--isolate-rooms" "$@"
    fi

    if [ "${SYNCPLAY_DISABLE_READY:-false}" = "true" ]; then
        set -- "--disable-ready" "$@"
    fi

    if [ "${SYNCPLAY_DISABLE_CHAT:-false}" = "true" ]; then
        set -- "--disable-chat" "$@"
    fi

    if [ -n "${SYNCPLAY_PASSWORD:-}" ]; then
        set -- "--password=${SYNCPLAY_PASSWORD}" "$@"
    fi

    if [ -n "${SYNCPLAY_MOTD_FILE:-}" ]; then
        set -- "--motd-file=${SYNCPLAY_MOTD_FILE}" "$@"
    fi

    if [ -n "${SYNCPLAY_ROOMS_DB_FILE:-}" ]; then
        set -- "--rooms-db-file=${SYNCPLAY_ROOMS_DB_FILE}" "$@"
    fi

    if [ -n "${SYNCPLAY_PERMANENT_ROOMS_FILE:-}" ]; then
        set -- "--permanent-rooms-file=${SYNCPLAY_PERMANENT_ROOMS_FILE}" "$@"
    fi

    if [ -n "${SYNCPLAY_MAX_CHAT_MESSAGE_LENGTH:-}" ]; then
        set -- "--max-chat-message-length=${SYNCPLAY_MAX_CHAT_MESSAGE_LENGTH}" "$@"
    fi

    if [ -n "${SYNCPLAY_MAX_USERNAME_LENGTH:-}" ]; then
        set -- "--max-username-length=${SYNCPLAY_MAX_USERNAME_LENGTH}" "$@"
    fi

    if [ -n "${SYNCPLAY_STATS_DB_FILE:-}" ]; then
        set -- "--stats-db-file=${SYNCPLAY_STATS_DB_FILE}" "$@"
    fi

    if [ -n "${SYNCPLAY_TLS:-}" ]; then
        set -- "--tls=${SYNCPLAY_TLS}" "$@"
    fi

    if [ "${SYNCPLAY_IPV4_ONLY:-false}" = "true" ]; then
        set -- "--ipv4-only" "$@"
    fi

    if [ "${SYNCPLAY_IPV6_ONLY:-false}" = "true" ]; then
        set -- "--ipv6-only" "$@"
    fi

    if [ -n "${SYNCPLAY_INTERFACE_IPV4:-}" ]; then
        set -- "--interface-ipv4=${SYNCPLAY_INTERFACE_IPV4}" "$@"
    fi

    if [ -n "${SYNCPLAY_INTERFACE_IPV6:-}" ]; then
        set -- "--interface-ipv6=${SYNCPLAY_INTERFACE_IPV6}" "$@"
    fi

    exec env PYTHONUNBUFFERED=1 \
        python /opt/syncplay/syncplayServer.py "$@"
}

main "$@"

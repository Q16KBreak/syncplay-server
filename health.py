#!/usr/bin/env python3

import os
import socket
import sys


def main():
    port = int(os.environ.get("SYNCPLAY_PORT", "8999"))
    request = b"GET / HTTP/1.1\r\nHost: localhost\r\n\r\n"

    try:
        with socket.create_connection(("127.0.0.1", port), timeout=3) as sock:
            sock.sendall(request)
            response = sock.recv(4096)

            if response:
                sys.exit(0)

    except (OSError, ValueError):
        pass

    sys.exit(1)


if __name__ == "__main__":
    main()

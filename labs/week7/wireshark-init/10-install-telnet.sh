#!/bin/bash
# Runs automatically on every container start (LinuxServer custom-cont-init.d).
# The base wireshark image ships no telnet client, so Exercise 8 (logging in
# via telnet from inside this container so the capture actually sees the
# traffic) fails with "telnet: not found" unless this is installed first.

echo "**** [wireshark-init] installing telnet client (busybox-extras) ****"
apk add --no-cache busybox-extras

#!/bin/bash
# Runs automatically on every container start (LinuxServer custom-cont-init.d).
# Hardened install: explicitly enables universe/multiverse before installing,
# rather than assuming the base image already has them enabled. Non-fatal on
# failure so a flaky mirror doesn't block the desktop from starting — see the
# "SecUtils GUI Box" section of this week's README for details/troubleshooting.

echo "**** [secutils-init] updating package index ****"
apt-get update -qq

echo "**** [secutils-init] ensuring universe/multiverse repos are enabled ****"
apt-get install -y --no-install-recommends software-properties-common -qq \
    || echo "**** [secutils-init] WARNING: could not install software-properties-common, add-apt-repository may be unavailable ****"
add-apt-repository -y universe   >/dev/null 2>&1
add-apt-repository -y multiverse >/dev/null 2>&1
apt-get update -qq

echo "**** [secutils-init] installing security tools (nmap, hydra, nikto, sqlmap, netcat) ****"
if apt-get install -y --no-install-recommends -qq \
    nmap \
    hydra \
    nikto \
    sqlmap \
    netcat-openbsd
then
    echo "**** [secutils-init] security tools installed successfully ****"
else
    echo "**** [secutils-init] WARNING: one or more packages failed to install — check network/mirror access. The desktop will still start. ****"
fi

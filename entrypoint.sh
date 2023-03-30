#!/bin/sh

chown cog: $SEATD_SOCK
# dbus needs the machine id to run
systemd-machine-id-setup
exec sudo -Eu cog dbus-launch cage -- cog "$@"

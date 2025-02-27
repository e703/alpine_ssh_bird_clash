#!/bin/sh
# start.sh
/usr/sbin/bird -c /etc/bird/bird.conf
/usr/sbin/sshd
/usr/local/bin/clash -d /etc/clash

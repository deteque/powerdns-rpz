#!/bin/sh
/usr/bin/docker run \
	--name powerdns \
	--rm \
	--detach \
	--publish 53:53/tcp \
	--publish 53:53/udp \
	-v /etc/powerdns:/etc/powerdns \
	x

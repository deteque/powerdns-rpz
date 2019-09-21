#!/bin/sh
/usr/bin/docker run --name powerdns --rm -d -p 53:53/udp -p 53:53/tcp powerdns

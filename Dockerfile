FROM debian:buster-slim
LABEL maintainer="Andrew Fried <afried@deteque.com>"
ENV POWERDNS_VERSION 4.3.3
ENV BUILD_DATE 2020-08-10

RUN 	apt-get clean \
	&& apt-get update \
	&& apt-get -y dist-upgrade \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg2 \
		lsb-release \
		locate \
		net-tools\
		procps \
		rsync \
		sipcalc \
		vim \
		wget 

# Install PowerDNS Recursor via their repository

COPY pdns.sources.list /etc/apt/sources.list.d/pdns.list
COPY pdns /etc/apt/preferences.d/pdns

RUN 	curl https://repo.powerdns.com/FD380FBB-pub.asc | apt-key add - \
 	&& apt-get update \
 	&& apt-get install --no-install-recommends --no-install-suggests -y pdns-recursor 

COPY recursor.conf /etc/powerdns/
COPY deteque-rpz.lua /etc/powerdns/

EXPOSE 53/tcp 53/udp

CMD ["/usr/sbin/pdns_recursor","--daemon=no"]

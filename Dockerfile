FROM debian:bookworm-slim
LABEL maintainer="Deteque <admin-deteque@spamhaus.com>"
ENV POWERDNS_VERSION 4.9.9
LABEL build_date "2025-06-06"
# UPDATE to 5.2+ requires converting to YAML configuration

RUN 	apt-get clean \
	&& apt-get update \
	&& apt-get -y dist-upgrade \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
		apt-transport-https \
		ca-certificates \
		curl \
		gpgv \
		lsb-release \
		locate \
		net-tools\
		procps \
		rsync \
		sipcalc \
		vim \
		pkg-config \
		procps \
		python3-pip \
		apt-utils \
		build-essential \
		dnstop \
		ethstats \
		libcap-dev \
		libcurl4-openssl-dev \
		libevent-dev \
		libpcap-dev \
		libreadline-dev \
		libssl-dev \
		libuv1-dev \
		libxml2-dev \
		sysstat \
		wget \
		python3-ply \
		git \
		autoconf \
		libtool \
		libboost-context-dev \
		libboost-filesystem-dev \
		libboost-system-dev \
		libboost-all-dev \
		libedit-dev \
		libboost-all-dev \
		liblua5.1-0-dev \
		libreadline-dev

RUN git clone --branch 21.x https://github.com/google/protobuf \
	&& git clone https://github.com/protobuf-c/protobuf-c \
	&& git clone https://github.com/farsightsec/fstrm 

RUN cd protobuf \
	&& autoreconf -i && ./configure && make; make install \
	&& cd .. \
	&& ldconfig

RUN cd protobuf-c \
	&& autoreconf -i && ./configure && make; make install \
	&& cd ..

RUN cd fstrm \
	&& autoreconf -i && ./configure && make; make install \
	&& cd .. \
	&& ldconfig \
	&& sync

RUN wget https://downloads.powerdns.com/releases/pdns-recursor-${POWERDNS_VERSION}.tar.bz2 \
	&& tar -xvjf pdns-recursor-${POWERDNS_VERSION}.tar.bz2 \
	&& cd pdns-recursor-${POWERDNS_VERSION} \
	&& ./configure \
		--enable-dnstap \
	&& make \
	&& make install \
	&& rm -rf /tmp/powerdns* \
	&& rm -rf /tmp/protobuf* \
	&& rm -rf /tmp/fstrm* \
	&& sync \
	&& ldconfig 


EXPOSE 53/tcp 53/udp

CMD ["/usr/local/sbin/pdns_recursor","--daemon=no","--config-dir=/etc/powerdns"]

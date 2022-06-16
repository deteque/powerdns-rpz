# deteque/powerdns-rpz
DNS Firewall based on PowerDNS Recursor and Deteque response policy zones (RPZ)

# Overview
The PowerDNS Recursor is capable of consuming commercial response policy zones (RPZ) and blocking DNS lookups based on those policies.  Deteque offers free access to the Deteque DROP RPZ zone, along with several other RPZ zones:
  * coinblocker.srv - blocks lookups of bitcoin type mining sites
  * doh.dtq - blocks DNS over HTTPS (DoH) for Firefox
  * drop.ip.dtq - the Spamhaus Don't Router or Peer list
  * porn.host.srv - a porn blocking list
  * torblock.srv - blocks access to Tor Exit Nodes

This docker image is "mostly" preconfigured to work out of the box.  In order to get PowerDNS to use RPZ, there are two mandatory changes that must be made to the configuration file.  First, in /etc/powerdns/recursor.conf you must uncomment and edit the line that begins with "lua-config-file=".  In our docker image, we have made that change to:
* lua-config-file=/etc/powerdns/deteque-rpz.lua

The file "deteque-rpz.lua" is included in /etc/powerdns/  This is the file that actually designates which RPZ zones the server will use and how to access them.  The file, as distributed, contains:

````
rpzPrimary({"34.194.195.25","35.156.219.71"}, "drop.ip.dtq", {defpol=Policy.NXDOMAIN,refresh=900})
-- rpzPrimary({"34.194.195.25","35.156.219.71"}, "coinblocker.srv", {defpol=Policy.NXDOMAIN,refresh=900})
-- rpzPrimary({"34.194.195.25","35.156.219.71"}, "doh.dtq", {defpol=Policy.NXDOMAIN,refresh=900})
-- rpzPrimary({"34.194.195.25","35.156.219.71"}, "porn.host.srv", {defpol=Policy.NXDOMAIN,refresh=900})
-- rpzPrimary({"34.194.195.25","35.156.219.71"}, "torblock.srv", {defpol=Policy.NXDOMAIN,refresh=900})
````

The only RPZ zone that defaults to active in this configuration is the drop.ip.dtq.  To selectively activate any of the other zones remove the leading "--" characters.  Please note that in order to access any of these zones you must first register an account with us and provide us with the IP address of your server.  Access to the servers is blocked by a firewall, so without an account you won't be able to connect. 

# Access restrictions
The recursor.conf file has a setting that restricts who can query the server.  Without restricting access to your server you become an open recursive server and will most assuredly be exploited for use in denial of service attacks.  The default settings we provide allow queries to originate from RFC-1918 private addresses.  If you are going run this docker image on a public Internet address you will have to modify the line at the top of the /etc/powerdns/recursor.conf file and add *only* your hostname or network:
* allow-from=127.0.0.0/8, 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16

# Starting the server
We've included a script that you can use to start this docker image:

````
#!/bin/sh
/usr/bin/docker run \
	--name powerdns \
	--rm \
	--detach \
	--publish 53:53/tcp \
	--publish 53:53/udp \
	deteque/powerdns-rpz
  ````

# Pointing at the server
You need to make sure you modify your client to point at the PowerDNS Resolver for DNS resolution.  You can send queries from a *unix server using "dig @127.0.0.1" from the server itself, or replace the 127.0.0.1 with whatever address that is assigned to the server.  Remember to query the server from an address/subnet that appears in the "allow-from" setting in your config.

# Testing the Installation
Assuming you have left drop.ip.dtq zone enabled, query our test record "drop.rpz.zone".  If that host resolves to an address of "127.127.127.127" something is wrong.  If the server is properly configured that query should return an nxdomain response (no such answer)".

# Logging
Normally, it's probably not a good idea to put an RPZ enabled server into a production environment without adequate logging.  Unfortunately, PowerDNS doens't provide an easy way to log rewrites (queries that get blocked); the only logging they offer is using dnstap.  A sample logger for Powerdns is avilable at https://github.com/spamhaus/pdns-logger.  If you require readable log files on the server itself you might want to consider using Bind.  We also offer a docker image for Bind that is enabled with RPZ.  You can pull that image using "docker pull deteque/bind-rpz".

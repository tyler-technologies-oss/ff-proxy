#!/bin/bash
# source - https://github.com/fanout/docker-pushpin/blob/master/docker-entrypoint.sh
set -e

# Configure Pushpin
if [ -w /usr/lib/pushpin/internal.conf ]; then
	sed -i \
		-e 's/zurl_out_specs=.*/zurl_out_specs=ipc:\/\/\{rundir\}\/pushpin-zurl-in/' \
		-e 's/zurl_out_stream_specs=.*/zurl_out_stream_specs=ipc:\/\/\{rundir\}\/pushpin-zurl-in-stream/' \
		-e 's/zurl_in_specs=.*/zurl_in_specs=ipc:\/\/\{rundir\}\/pushpin-zurl-out/' \
		/usr/lib/pushpin/internal.conf
else
	echo "docker-entrypoint.sh: unable to write to /usr/lib/pushpin/internal.conf, readonly"
fi

if [ -w /etc/pushpin/pushpin.conf ]; then
	sed -i \
		-e 's/services=.*/services=condure,zurl,pushpin-proxy,pushpin-handler/' \
		-e 's/push_in_spec=.*/push_in_spec=tcp:\/\/\*:5560/' \
		-e 's/push_in_http_addr=.*/push_in_http_addr=0.0.0.0/' \
		-e 's/push_in_sub_specs=.*/push_in_sub_spec=tcp:\/\/\*:5562/' \
		-e 's/command_spec=.*/command_spec=tcp:\/\/\*:5563/' \
		/etc/pushpin/pushpin.conf
else
	echo "docker-entrypoint.sh: unable to write to /etc/pushpin/pushpin.conf, readonly"
fi

# Set routes with ${target} for backwards-compatibility.
if [ -v target ]; then
	echo "* ${target},over_http" > /etc/pushpin/routes
fi

# Update pushpin.conf file to use $PORT for http_port
if [ -w /etc/pushpin/pushpin.conf ]; then
  if [ -n "${PORT}" ]; then
    echo "Listening for requests on port ${PORT}"
    sed -i \
		-e "s/http_port=7000/http_port=${PORT}/" \
		/etc/pushpin/pushpin.conf
		export PORT=
  fi
else
	echo "docker-entrypoint.sh: unable to write to /etc/pushpin/pushpin.conf, readonly"
fi

exec "$@"

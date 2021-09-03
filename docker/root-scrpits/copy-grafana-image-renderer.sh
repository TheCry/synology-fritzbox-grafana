#!/bin/bash

PLUGINDIR="/var/lib/grafana/plugins"
DIR="/var/lib/grafana/plugins/grafana-image-renderer"
if [ ! -d "$DIR" ]; then
	if [ ! -d "$PLUGINDIR" ]; then
		mkdir -p $PLUGINDIR
	fi
	cp -r /root/grafana-plugins/grafana-image-renderer/ $PLUGINDIR
	chown -R grafana:grafana $PLUGINDIR
fi

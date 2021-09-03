# Synology NAS and FRITZ!Box Router monitoring
This project builds on the template from https://github.com/alhazmy13/Synology-NAS-monitoring. The Docker container was built with Debian 11 (Bullseye) and the latest packages:
* TELEGRAF => 1.19.3-1
* INFLUXDB => 1.8.9
* GRAFANA => 8.1.2
* CHRONOGRAF => 1.9.0

## Synology NAS Dashboard
This dashboard was created by "alhazmy13":
https://grafana.com/grafana/dashboards/14590 (Synology DashBoardby alhazmy13)

![alt text](https://github.com/TheCry/synology-fritzbox-grafana/blob/main/images/dashboard.png)


## FRITZ!Box Router Dashboard
This dashboard was created by "Christian Fetzer":
https://grafana.com/grafana/dashboards/713 (FRITZ!Box Router Statusby Christian Fetzer)

![alt text](https://github.com/TheCry/synology-fritzbox-grafana/blob/main/images/grafana-fitzbox.jpg)

## Requirements
* Installation of Docker on Synology NAS
* Enable SNMP on Synology NAS
* Enable Logging on Synology NAS
* Adding folders on Synology NAS to store data
* Add FRITZ!Box user for query status

## Installing Docker on Synology NAS
1. Install Docker from Synology package center

## Enable SNMP on Synology NAS
1. From Control panel in your Synology NAS go to Terminal & SNMP
2. Click on SNMP tab, and enable SNMPv1, SNMPv2 service
3. in Community input put ***public***
4. Save

## Create needed folders on Synology NAS
1. Create four empty folders in your Synology ***collectd***, ***collectd-conf.d***, ***grafana*** and ***influxdb*** (On Synology NAS under "docker")

![alt text](https://github.com/TheCry/synology-fritzbox-grafana/blob/main/images/synology-folder-2.JPG)

## Create collectd FRITZ!Box Router file
1. Create a file with the FRITZ!Box user login data (Template: https://github.com/TheCry/synology-fritzbox-grafana/blob/main/collectd-fritzbox/fritzcollectd.conf)
2. Upload "fritzcollectd.conf" on the Synology NAS to the created folder "collectd-conf.d"

## Run Docker image in your Synology NAS
1. Open Docker client from Synology > Image > Add > Add from url and paste Hub page url "https://hub.docker.com/repository/docker/space2place/synology-fritzbox-grafana"
2. Wait until it finishes downloading the image
3. Click on the image "space2place/synology-fritzbox-grafana" and then click on Launch 
4. Click on Advanced Settings and check "Enable auto-restart."
5. From the Volume tab, click "Add folder" and select the first folder that we created, "collectd" and on mount Path, paste ***/var/lib/collectd***
6. From the Volume tab again, click "Add Folder" and select the second folder that we created "collectd-conf.d" and on mount Path paste ***/etc/collectd/collectd.conf.d***
7. From the Volume tab again, click "Add folder" and select the third folder that we created, "grafana" and on mount Path, paste ***/var/lib/grafana***
8. From the Volume tab again, click "Add Folder" and select the fourth folder that we created "influxdb" and on mount Path paste ***/var/lib/influxdb***

![alt text](https://github.com/TheCry/synology-fritzbox-grafana/blob/main/images/start-container_extended_volumes.JPG)

9. Network Tab keep it in bridge mode
10. Port settings, just change Local port for 3003 from Auto to 3003, and port 514 from Auto to 5144

![alt text](https://github.com/TheCry/synology-fritzbox-grafana/blob/main/images/start-container_extended_ports.JPG)

11. Environment Tab > Add new variable "TZ" with your local time zone **ignore this if you want to use the default UTC**
12. Apply, Next, Done and your container should be ready.

## Start Grafana
1. Open [http://YOUR_LOCAL_NAS_IP:3003](http://YOUR_LOCAL_NAS_IP:3003) and login with the default username ***root*** and password ***root***
2. You need to import the Synology NAS dashboard. To do this, go to [http://YOUR_LOCAL_NAS_IP:3003/dashboard/import](http://YOUR_LOCAL_NAS_IP:3003/dashboard/import) and put ***14590*** in "Import via grafana.com" input
3. Attach the "Data Source" ***InfluxDB-Synonlogy*** to the Synology NAS dashboard
4. Click on load and complete the process
5. You need to import the FRITZ!Box Router dashboard. To do this, go to [http://YOUR_LOCAL_NAS_IP:3003/dashboard/import](http://YOUR_LOCAL_NAS_IP:3003/dashboard/import) and put ***713*** in "Import via grafana.com" input
6. Attach the "Data Source" ***InfluxDB-FritzBox*** to the FRITZ!Box Router dashboard
7. Click on load and complete the process

## Enable Logging
1. Install Log center From Synology package center
2. Open Log center app
3. Click on Log Sending > check "Send log to syslog server"
3. Set Server = ***localhost***,  port = ***5144***, Protocol = ***UDP***, Format = ***BSD (RFC 3164)***
4. For testing, click on "Send test log" 
4. Apply

## Using graphs in external tools like ioBroker
Yes it is possible. Grafana is configured with ***allow_embedding = true*** and ***auth.anonymous***.
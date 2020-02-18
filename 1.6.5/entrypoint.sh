#!/bin/bash
if [ -z "$(ls -A -- "/usr/local/lsws/conf/")" ]; then
cp -R /usr/local/lsws/.conf/* /usr/local/lsws/conf/
fi
chown 999:999 /usr/local/lsws/conf -R
chown 999:1000 /usr/local/lsws/admin/conf -R
#start ols and ping it every 60 second to make sure it running, if not exist container (assuming ols crashed)
$@
while true; do
	if ! /usr/local/lsws/bin/lswsctrl status | grep 'litespeed is running with PID *' > /dev/null; then
		break
	fi
	sleep 60
done


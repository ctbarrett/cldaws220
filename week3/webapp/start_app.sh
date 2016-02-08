#!/bin/bash

appdir=/home/web/webapp
pidfile=$appdir/app.pid

[[ -f $pidfile ]] && pid=$(<$pidfile)

running_pid=$(ps -ef|awk '/ruby.*webapp\/app.rb/ {print $2}')

if [[ ! -f $pidfile ]] && [[ -n $running_pid ]]
then
  echo "Server running as PID: $running_pid."
  echo $running_pid >$pidfile
  exit
elif [[ -f $pidfile ]] && [[ $pid -ne $(ps -ef|awk '/ruby.*webapp\/app.rb/ {print $2}') ]]
then
  echo "Server running as PID: $(ps -ef|awk '/ruby.*webapp\/app.rb/ {print $2}')"
  echo $(ps -ef|awk '/ruby.*webapp\/app.rb/ {print $2}') >$pidfile
  exit
elif [[ -f $pidfile ]] && ps -fp $pid >/dev/null 2>&1
then
  echo "Server running as PID: $pid" >&2
  exit
elif [[ -f $pidfile ]] && ! ps -fp $pid >/dev/null 2>&1
then
  echo "PID file exists, but no process running... cleaning up & restarting server."
  rm $pidfile
  /usr/bin/nohup /usr/bin/ruby $appdir/app.rb </dev/null >>$appdir/app.log 2>&1 &
  echo $! >$pidfile
else
  echo "Starting webapp..."
  /usr/bin/nohup /usr/bin/ruby $appdir/app.rb </dev/null >>$appdir/app.log 2>&1 &
  echo $! >$pidfile
fi

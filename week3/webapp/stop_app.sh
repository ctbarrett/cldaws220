#!/bin/bash

appdir=/home/web/webapp
pidfile=$appdir/app.pid

[[ -f $pidfile ]] && pid=$(<$pidfile)

if [[ -f $pidfile ]] && ps -fp $pid >/dev/null 2>&1
then
  echo "Stopping server on PID: $pid"
  kill $pid
  rm $pidfile
  exit
elif [[ -f $pidfile ]]
then
  echo "PID file exists, but no process running... cleaning up."
  rm $pidfile
  exit
fi

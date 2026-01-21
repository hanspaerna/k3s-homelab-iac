#!/bin/sh
curl http://192.168.8.158/cm?cmnd=POWER -w "\n"
printf '\n'
curl http://192.168.8.158/cm?cmnd=status -w "\n"
printf '\n'
curl http://192.168.8.158/cm?cmnd=status%2010 -w "\n"

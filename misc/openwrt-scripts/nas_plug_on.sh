#!/bin/sh

read -p "[WARNING] This will POWER ON the NAS plug. Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    curl http://192.168.8.158/cm?cmnd=Power%20On -w "\n"
fi

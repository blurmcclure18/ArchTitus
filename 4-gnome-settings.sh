#!/usr/bin/env bash

mkdir /etc/dconf/profile
mkdir /etc/dconf/db/local.d
cp /root/ArchTitus/gnomesettings/user /etc/dconf/profile
cp /root/ArchTitus/gnomesettings/local /etc/dconf/db
cp /root/ArchTitus/gnomesettings/00-settings /etc/dconf/db/local.d

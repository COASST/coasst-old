#!/usr/bin/env bash

# extract the archive to the root of the system
tar xvpfj backup.tar.gz -C /

# networking is statically configured by default, overwrite with dhcp settings
cp interfaces /etc/network/
/etc/init.d/networking restart

# grab current IP address
IP=`ifconfig | awk -F' |:' '/sk/&&$0=$13'| grep -v '0.1'`

# set the coasst apache configuration file to bind on that address
sed 's/67.207.132.87/'$IP'/g' /etc/apache2/sites-available/coasst > /etc/apache2/sites-available/coasst_tmp
mv /etc/apache2/sites-available/coasst_tmp /etc/apache2/sites-available/coasst

# restart apache with new configuration
/etc/init.d/apache2 reload

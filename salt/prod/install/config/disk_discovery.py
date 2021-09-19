#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import json

disks = [ disk for disk in os.listdir("/sys/block") if not disk.startswith(('sr','dm')) ]
list = []

for disk in disks:
    size = os.popen("sudo /sbin/blockdev --getss /dev/%s" % disk)
    list.append({"{#DISK_NAME}": "/dev/%s" % disk,"{#SEC_SIZE}": size.read().strip()})

print json.dumps({"data": list})

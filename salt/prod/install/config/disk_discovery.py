#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import json

disk_list = [ "/dev/"+disk for disk in os.listdir("/sys/block") if not disk.startswith(('sr','dm')) ]
disk_dict = []

for disk in disk_list:
    size = os.popen("sudo /sbin/blockdev --getss %s" % disk)
    disk_dict.append({"{#DISK_NAME}":disk,"{#SEC_SIZE}":size.read().strip()})

print json.dumps({"data": disk_dict})

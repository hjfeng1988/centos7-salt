#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import json

db_dict = []
dbs = os.popen("source /var/lib/zabbix/.redis.auth;redis-cli -a $password info keyspace")

for line in dbs.readlines():
  if '#' not in line:
    db_dict.append({"{#DB_NUMBER}":line.strip().split(':')[0]})

print json.dumps({"data": db_dict})

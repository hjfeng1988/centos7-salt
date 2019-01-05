#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import json

db_dict = []
dbs = os.popen("redis-cli -a pass info keyspace")

for line in dbs.readlines():
  if '#' not in line:
    db_dict.append({"{#DB_NUMBER}":line.strip().split(':')[0]})

print json.dumps({"data": db_dict})

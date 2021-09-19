#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import json

path = '/usr/local/bluecloud/lib'
javas = [ dir for dir in os.listdir(path)]
list = []

for java in javas:
    list.append({"{#JAVA_NAME}":java})

print json.dumps({"data": list})

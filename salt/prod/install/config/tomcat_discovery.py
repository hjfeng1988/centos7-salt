#!/usr/bin/env python
#-*- coding:utf-8 -*-

import os
import json

path = '/usr/local'
key = 'tomcat_'
tomcats = [ dir for dir in os.listdir(path) if dir.startswith(key) ]
list = []

for tomcat in tomcats:
    list.append({"{#TOMCAT_NAME}":tomcat+"/"})

print json.dumps({"data": list})

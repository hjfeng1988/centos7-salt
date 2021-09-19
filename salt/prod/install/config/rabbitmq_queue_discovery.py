#!/bin/env python
# -*- coding: UTF-8 -*-
import urllib2, base64, json, os, sys

request = urllib2.Request("http://localhost:15672/api/queues")
base64string = base64.b64encode('zabbix:pass')
request.add_header("Authorization", "Basic %s" % base64string)
result = urllib2.urlopen(request)
data = json.loads(result.read())
queue_dict = []
for queue in data:
  if len(sys.argv) > 1:
    if sys.argv[1] in queue['name']:
      queue_dict.append({"{#QUEUE_NAME}":queue['name'].replace('@','%'),"{#QUEUE_VHOST}":queue['vhost']})
  else:
    if not queue['name'].startswith(('springCloudBus')) and not '@' in queue['name']:
      queue_dict.append({"{#QUEUE_NAME}":queue['name'],"{#QUEUE_VHOST}":queue['vhost']})

print json.dumps({"data": queue_dict})

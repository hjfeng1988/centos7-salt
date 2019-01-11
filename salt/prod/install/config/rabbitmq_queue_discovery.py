#!/bin/env python
# -*- coding: UTF-8 -*-
import urllib2, base64, json

request = urllib2.Request("http://localhost:15672/api/queues")
base64string = base64.b64encode('zabbix:pass')
request.add_header("Authorization", "Basic %s" % base64string)
result = urllib2.urlopen(request)
data = json.loads(result.read())
queue_dict = []
for queue in data:
  if not queue['name'].startswith(('springCloudBus')):
    queue_dict.append({"{#QUEUE_NAME}":queue['name'],"{#QUEUE_VHOST}":queue['vhost']})

print json.dumps({"data": queue_dict}) 

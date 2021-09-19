#!/bin/env python
# -*- coding: UTF-8 -*-
import urllib2, base64, json, sys

request = urllib2.Request("http://localhost:15672/api/queues/%s/%s" % (sys.argv[1],sys.argv[2].replace('%','@')))
base64string = base64.b64encode('zabbix:pass')
request.add_header("Authorization", "Basic %s" % base64string)
result = json.loads(urllib2.urlopen(request).read())
print result[sys.argv[3]]

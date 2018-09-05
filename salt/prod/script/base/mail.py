#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys,os
import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

if len(sys.argv) < 4:
    print sys.argv[0],"mail_to subject content/htmlfile"
    sys.exit()

mail_from = "monitor@ulandian.com"
mail_pass = "pass"
mail_to = sys.argv[1]
subject = sys.argv[2]
argv3 = sys.argv[3]

if os.path.exists(argv3):
    f = open(argv3,'r')
    content = f.read()
    f.close()
    type = "html"
else:
    content = argv3
    type = "plain"
    
# 构造邮件
msg = MIMEText(content,type,'utf-8')
msg['From'] = mail_from
msg['To'] = mail_to
msg['Subject'] = subject

# 发送邮件
server = smtplib.SMTP_SSL()
server.connect('smtp.ulandian.com')
server.login(mail_from,mail_pass)
server.sendmail(mail_from, mail_to.split(','), msg.as_string())
server.quit()

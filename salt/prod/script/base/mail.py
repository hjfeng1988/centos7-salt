#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys,os
import smtplib
from email.mime.text import MIMEText

if len(sys.argv) < 4:
    print sys.argv[0],"mail_to subject content/htmlfile"
    sys.exit()

mail_server = "smtp.your.com"
mail_from = "monitor@your.com"
mail_pass = "pass"
mail_to = sys.argv[1]
mail_subject = sys.argv[2]
mail_content = sys.argv[3]

if os.path.exists(mail_content):
    f = open(mail_content,'r')
    content = f.read()
    f.close()
    type = "html"
else:
    content = mail_content
    type = "plain"
    
# 构造邮件
msg = MIMEText(content,type,'utf-8')
msg['From'] = mail_from
msg['To'] = mail_to
msg['Subject'] = mail_subject

# 发送邮件
server = smtplib.SMTP_SSL(mail_server)
server.login(mail_from,mail_pass)
server.sendmail(mail_from, mail_to.split(','), msg.as_string())
server.quit()

# /etc/sudoers 添加admin、super群组sudo权限
/etc/sudoers:
  file.append:
    - text: |
        Cmnd_Alias DELEGATING = /usr/sbin/visudo, /bin/chown, /bin/chmod, /bin/chgrp
        %admin        ALL=(ALL)        NOPASSWD: ALL
        %super        ALL=(ALL)        NOPASSWD: ALL,!DELEGATING
        %tomcat       ALL=(ALL)        NOPASSWD: /data/script/ctrl_tomcat.sh

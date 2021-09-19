include:
  - install.jdk
  - script.web
  - cron.web
  - user.gitlab

tomcat-install:
  file.recurse:
    - name: /usr/local/tomcat_weixin
    - source: salt://install/soft/tomcat_weixin
    - unless: test -d /usr/local/tomcat_weixin
  cmd.run:
    - name: |
        useradd -r -s /sbin/nologin tomcat
        chown -R tomcat:tomcat /usr/local/tomcat_weixin

tomcat-logrotate:
  file.managed:
    - name: /etc/logrotate.d/tomcat
    - source: salt://install/config/tomcat
    - require:
      - cmd: tomcat-install

tomcat-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/tomcat_weixin.service
    - source: salt://install/config/tomcat_weixin.service
    - require:
      - cmd: tomcat-install

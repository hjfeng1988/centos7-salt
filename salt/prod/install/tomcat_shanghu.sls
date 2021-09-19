include:
  - install.jdk
  - script.web
  - cron.web
  - user.gitlab

tomcat-install:
  file.recurse:
    - name: /usr/local/tomcat_shanghu
    - source: salt://install/soft/tomcat_shanghu
    - unless: test -d /usr/local/tomcat_shanghu
  cmd.run:
    - name: |
        useradd -r -s /sbin/nologin tomcat
        chown -R tomcat:tomcat /usr/local/tomcat_shanghu

tomcat-logrotate:
  file.managed:
    - name: /etc/logrotate.d/tomcat
    - source: salt://install/config/tomcat
    - require:
      - cmd: tomcat-install

tomcat-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/tomcat_shanghu.service
    - source: salt://install/config/tomcat_shanghu.service
    - require:
      - cmd: tomcat-install

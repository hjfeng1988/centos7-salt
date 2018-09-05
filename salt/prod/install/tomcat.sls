include:
  - install.jdk
{#
{% set version = '7.0.86' %}
#} 
{% set version = '7.0.68' %}
tomcat-install:
  file.managed:
    - name: /usr/local/src/apache-tomcat-{{ version }}.tar.gz
    - source: salt://install/soft/apache-tomcat-{{ version }}.tar.gz
  cmd.run:
    - name: |
        cd /usr/local/src
        tar -zxf apache-tomcat-{{ version }}.tar.gz
        mv apache-tomcat-{{ version }} /usr/local/tomcat
        rm /usr/local/tomcat/webapps/* -rf
        rm /usr/local/tomcat/conf/server.xml -f
        useradd -r -s /sbin/nologin tomcat
        chown -R tomcat:tomcat /usr/local/tomcat
    - unless: test -d /usr/local/tomcat

tomcat-conf1:
  file.managed:
    - name: /usr/local/tomcat/conf/server.xml
    - source: salt://install/config/server.xml
    - require:
      - cmd: tomcat-install

tomcat-conf2:
  file.managed:
    - name: /usr/local/tomcat/conf/logging.properties
    - source: salt://install/config/logging.properties
    - require:
      - cmd: tomcat-install

tomcat-setenv.sh:
  file.managed:
    - name: /usr/local/tomcat/bin/setenv.sh
    - source: salt://install/config/setenv.sh
    - require:
      - cmd: tomcat-install

tomcat-logrotate:
  file.managed:
    - name: /etc/logrotate.d/tomcat
    - source: salt://install/config/tomcat
    - require:
      - cmd: tomcat-install

tomcat-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/tomcat.service
    - source: salt://install/config/tomcat.service
    - require:
      - cmd: tomcat-install

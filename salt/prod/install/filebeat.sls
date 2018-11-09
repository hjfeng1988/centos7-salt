filebeat-repo:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
  file.managed:
    - name: /etc/yum.repos.d/elastic.repo
    - source: salt://install/config/elastic.repo

filebeat-install:
  pkg.installed:
    - name: filebeat
    - version: 6.4.0
    - require:
      - file: filebeat-repo
  cmd.run:
    - name: filebeat modules enable system
    - unless: filebeat modules list | sed -n '/Enabled/,/Disabled/p' | grep system
    - require:
      - pkg: filebeat-install

filebeat-conf:
  file.managed:
    - name: /etc/filebeat/filebeat.yml
    - source: salt://install/config/filebeat.yml
    - require:
      - pkg: filebeat-install
  service.running:
    - name: filebeat
    - enable: true
    - watch_any:
      - file: filebeat-conf
      - cmd: filebeat-install

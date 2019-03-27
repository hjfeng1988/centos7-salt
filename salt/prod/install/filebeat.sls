filebeat-repo:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    - unless: rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep -q Elasticsearch
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
    - require:
      - pkg: filebeat-install

filebeat-conf-mysql:
  cmd.run:
    - name: filebeat modules enable mysql
    - onlyif:
      - rpm --quiet -q mysql-community-server
    - unless:
      - filebeat modules list | sed -n '/Enabled/,/Disabled/p' | grep -q mysql
    - require:
      - pkg: filebeat-install
  file.managed:
    - name: /etc/filebeat/modules.d/mysql.yml
    - source: salt://install/config/mysql.yml
    - onlyif: rpm --quiet -q mysql-community-server
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
      - file: filebeat-conf-mysql
      - cmd: filebeat-install

filebeat-repo:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    - unless: rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep -q Elasticsearch
  file.managed:
    - name: /etc/yum.repos.d/elastic.repo
    - source: salt://install/config/elastic.repo

filebeat-install:
  file.managed:
    - name: /usr/local/src/filebeat-7.8.0-x86_64.rpm
    - source: salt://install/soft/filebeat-7.8.0-x86_64.rpm
  cmd.run:
    - name: |
        yum clean all
        yum localinstall /usr/local/src/filebeat-7.8.0-x86_64.rpm -y
    - require:
      - file: filebeat-repo
      - file: filebeat-install

filebeat-conf:
  file.managed:
    - name: /etc/filebeat/filebeat.yml
    {% if "tomcat" in grains['host'] %}
    - source: salt://install/config/filebeat_tomcat.yml
    {% elif "bluecloud" in grains['host'] %}
    - source: salt://install/config/filebeat_bluecloud.yml
    {% elif "bc" in grains['host'] %}
    - source: salt://install/config/filebeat_bluecloud.yml
    {% endif %}
    - require:
      - cmd: filebeat-install
  service.running:
    - name: filebeat
    - enable: true
    - watch_any:
      - file: filebeat-conf

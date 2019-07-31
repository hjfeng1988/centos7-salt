logstash-repo:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    - unless: rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep -q Elasticsearch
  file.managed:
    - name: /etc/yum.repos.d/elastic.repo
    - source: salt://install/config/elastic.repo
    - require:
      - cmd: logstash-repo

openjdk-install:
  pkg.installed:
    - name: java-1.8.0-openjdk

logstash-install:
  pkg.installed:
    - name: logstash
    - version: 6.4.0
    - require:
      - file: logstash-repo
      - pkg: openjdk-install

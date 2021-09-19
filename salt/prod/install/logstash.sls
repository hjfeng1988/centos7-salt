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

# /etc/yum.repos.d/elastic.repo disable default to speed up other soft when yum.
#logstash-install:
#  pkg.installed:
#    - name: logstash
#    - version: 7.5.0
#    - require:
#      - file: logstash-repo
#      - pkg: openjdk-install
logstash-install:
  cmd.run:
    - name: yum install -y logstash-7.5.0 --enablerepo elasticsearch

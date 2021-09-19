elasticsearch-repo:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
    - unless: rpm -q gpg-pubkey --qf '%{NAME}-%{VERSION}-%{RELEASE}\t%{SUMMARY}\n' | grep -q Elasticsearch
  file.managed:
    - name: /etc/yum.repos.d/elastic.repo
    - source: salt://install/config/elastic.repo
    - require:
      - cmd: elasticsearch-repo

openjdk-install:
  pkg.installed:
    - name: java-1.8.0-openjdk

# /etc/yum.repos.d/elastic.repo disable for yum other software speed
#elasticsearch-install:
#  pkg.installed:
#    - name: elasticsearch
#    - version: 7.0.0
#    - require:
#      - file: elasticsearch-repo
#      - pkg: openjdk-install
#elasticsearch-install:
#  cmd.run:
#    - name: yum install -y elasticsearch-7.5.0 --enablerepo elasticsearch

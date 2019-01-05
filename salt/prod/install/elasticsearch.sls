elasticsearch-repo:
  cmd.run:
    - name: rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
  file.managed:
    - name: /etc/yum.repos.d/elastic.repo
    - source: salt://install/config/elastic.repo

openjdk-install:
  pkg.installed:
    - name: java-1.8.0-openjdk

elasticsearch-install:
  pkg.installed:
    - name: elasticsearch
    - require:
      - file: elasticsearch-repo
      - pkg: openjdk-install

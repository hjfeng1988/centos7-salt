node_exporter-install:
  file.managed:
    - name: /usr/local/src/node_exporter-0.18.1.linux-amd64.tar.gz
    - source: salt://install/soft/node_exporter-0.18.1.linux-amd64.tar.gz
  cmd.run:
    - name: |
        cd /usr/local/src
        tar -zxf node_exporter-0.18.1.linux-amd64.tar.gz
        mv node_exporter-0.18.1.linux-amd64 /usr/local/node_exporter
    - unless: test -d /usr/local/node_exporter

node_exporter-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/node_exporter.service
    - source: salt://install/config/node_exporter.service
    - require:
      - cmd: node_exporter-install
  service.running:
    - name: node_exporter
    - enable: true
    - require:
      - file: node_exporter-systemd

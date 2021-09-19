promtail-install:
  file.managed:
    - name: /usr/local/src/promtail-linux-amd64.zip
    - source: salt://install/soft/promtail-linux-amd64.zip
  cmd.run:
    - name: |
        cd /usr/local/src
        unzip promtail-linux-amd64.zip
        mv promtail-linux-amd64 /usr/local/bin/promtail
    - unless: test -f /usr/local/bin/promtail

{% set loki_1 = '192.168.0.101' %}
{% set loki_2 = '172.16.2.98' %}

promtail-conf:
  file.managed:
    - name: /etc/promtail.yaml
    - source: salt://install/config/promtail.yaml
    - template: jinja
    - defaults:
      host_name: {{ grains['id'] }}
    {% if "SH1" in grains['id'] %}
      loki_ip: {{ loki_2 }}
    {% elif "XM" in grains['id'] %}
      loki_ip: {{ loki_1 }}
    {% else %}
      loki_ip: {{ loki_1 }}
    {% endif %}
    - require:
      - cmd: promtail-install

promtail-systemd:
  file.managed:
    - name: /usr/lib/systemd/system/promtail.service
    - source: salt://install/config/promtail.service
    - require:
      - cmd: promtail-install
  service.running:
    - name: promtail
    - enable: true
    - watch:
      - file: /etc/promtail.yaml
    - require:
      - file: promtail-conf

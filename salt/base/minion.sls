salt-repo:
  cmd.run:
    - name: |
        yum install -y https://repo.saltstack.com/yum/redhat/salt-repo-latest.el7.noarch.rpm
        yum clean expire-cache
        pip uninstall -y urllib3 || true
    - unless: rpm --quiet -q salt-repo

{% set salt_master = '172.16.2.95' %}

salt-minion:
  pkg.latest:
    - require:
      - cmd: salt-repo
  cmd.run:
    - name: rm -f /etc/salt/minion
    - unless: grep "{{ grains['id'] }}" /etc/salt/minion
  file.managed:
    - name: /etc/salt/minion
    - source: salt://config/minion
    - template: jinja
    - defaults:
    {% if "HD1" in grains['host'] %}
      master_ip: {{ salt_master }}
    {% else %}
      master_ip: {{ pillar['salt_master']['ip'] }}
    {% endif %}
      minion_id: {{ grains['id'] }}
    - require:
      - pkg: salt-minion
  service.running:
    - enable: True
    - watch:
      - file: /etc/salt/minion

epel-release:
  pkg.installed:
    - name: epel-release

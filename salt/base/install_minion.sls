salt-repo:
  cmd.run:
    - name: |
        yum install https://repo.saltstack.com/yum/redhat/salt-repo-3000.el7.noarch.rpm -y
        #yum clean expire-cache
        #pip uninstall urllib3 -y
        #pip install urllib3==1.22 || true

{% set internal_salt_master = '172.16.2.99' %}
{% set external_salt_master = '1.1.1.1' %}

salt-minion:
  pkg.latest:
    - require:
      - cmd: salt-repo
  # reduce output of file.manage.
  cmd.run:
    - name: rm -f /etc/salt/minion
    - unless: grep "{{ grains['id'] }}" /etc/salt/minion
  file.managed:
    - name: /etc/salt/minion
    - source: salt://config/minion
    - template: jinja
    - defaults:
    {% if "SH1" in grains['id'] %}
      master_ip: {{ internal_salt_master }}
    {% else %}
      master_ip: {{ external_salt_master }}
    {% endif %}
      minion_id: {{ grains['id'] }}
    - require:
      - pkg: salt-minion
  service.running:
    - enable: True
    - watch:
      - file: /etc/salt/minion

salt-repo:
  cmd.run:
    - name: |
        yum -y install https://repo.saltstack.com/yum/redhat/salt-repo-2017.7-1.el7.noarch.rpm
        yum clean expire-cache
        pip uninstall -y urllib3 || true

salt-minion:
  pkg.latest:
    - require:
      - cmd: salt-repo
  cmd.run:
    - name: rm -f /etc/salt/minion
  file.managed:
    - name: /etc/salt/minion
    - source: salt://config/minion
    - template: jinja
    - defaults:
      master_ip: {{ pillar['salt_master']['ip'] }}
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

zabbix-repo:
  cmd.run:
    - name: rpm -i https://repo.zabbix.com/zabbix/3.4/rhel/7/x86_64/zabbix-release-3.4-2.el7.noarch.rpm
    - unless: rpm --quiet -q zabbix-release

zabbix-install:
  pkg.installed:
    - name: zabbix-agent
    - version: 3.4.10
    - require:
      - cmd: zabbix-repo

zabbix-file1:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/disk_discovery.py
    - source: salt://install/config/disk_discovery.py
    - require:
      - pkg: zabbix-install
zabbix-file2:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/userparameter_custom.conf
    - source: salt://install/config/userparameter_custom.conf
    - require:
      - pkg: zabbix-install

zabbix-conf1:
  file.replace:
    - name: /etc/zabbix/zabbix_agentd.conf
    - pattern: '^Server=.*'
    {% if "172.16" in grains['fqdn_ip4']|string %}
    - repl: 'Server=172.16.2.95'
    {% else %}
    - repl: 'Server=192.168.0.101'
    {% endif %}
    - require:
      - pkg: zabbix-install

zabbix-conf2:
  file.replace:
    - name: /etc/zabbix/zabbix_agentd.conf
    - pattern: '^ServerActive'
    - repl: '#ServerActive'
    - require:
      - pkg: zabbix-install
  service.running:
    - name: zabbix-agent
    - enable: true
    - watch_any:
      - file: zabbix-conf1
      - file: zabbix-conf2
      - file: zabbix-file2

/etc/sudoers.d/zabbix:
  file.append:
    - text: "zabbix        ALL=(ALL)        NOPASSWD: /sbin/blockdev"


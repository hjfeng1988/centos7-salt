zabbix-repo:
  cmd.run:
    - name: rpm -Uvh https://repo.zabbix.com/zabbix/4.0/rhel/7/x86_64/zabbix-release-4.0-1.el7.noarch.rpm
    - unless: rpm --quiet -q zabbix-release-4.0

zabbix-install:
  pkg.latest:
#  pkg.installed:
    - name: zabbix-agent
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
    - repl: 'Server={{ pillar['hd1g_zabbix_proxy']['ip'] }}'
    {% else %}
    - repl: 'Server={{ pillar['zabbix_server']['ip'] }}'
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

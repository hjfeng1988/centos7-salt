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

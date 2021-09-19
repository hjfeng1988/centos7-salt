zabbix-repo:
  file.managed:
    - name: /etc/yum.repos.d/zabbix.repo
    - source: salt://install/config/zabbix.repo

{% set sh1b_zabbix_proxy = '172.16.2.99' %}
{% set zabbix_server = '192.168.0.101' %}

zabbix-install:
  cmd.run:
    - name: |
        curl https://mirrors.tuna.tsinghua.edu.cn/zabbix/RPM-GPG-KEY-ZABBIX-A14FE591 -o /etc/pki/rpm-gpg/RPM-GPG-KEY-ZABBIX-A14FE591
    - require:
      - file: zabbix-repo
  #pkg.latest:
  pkg.installed:
    - name: zabbix-agent
    - version: 5.0.7
    - require:
      - file: zabbix-repo

zabbix-file1:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/tomcat_discovery.py
    - source: salt://install/config/tomcat_discovery.py
    - onlyif:
      - ls /usr/local | grep -q tomcat
    - require:
      - pkg: zabbix-install
zabbix-file2:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/bluecloud_discovery.py
    - source: salt://install/config/bluecloud_discovery.py
    - onlyif:
      - ls /usr/local | grep -q bluecloud
    - require:
      - pkg: zabbix-install
zabbix-file3:
  file.managed:
    - name: /etc/zabbix/zabbix_agentd.d/userparameter_custom.conf
    - source: salt://install/config/userparameter_custom.conf
    - require:
      - pkg: zabbix-install

zabbix-conf1:
  file.replace:
    - name: /etc/zabbix/zabbix_agentd.conf
    - pattern: '^Server=.*'
    {% if "SH1" in grains['id'] %}
    - repl: 'Server={{ sh1b_zabbix_proxy }}'
    {% elif "XM" in grains['id'] %}
    - repl: 'Server={{ zabbix_server }}'
    {% else %}
    - repl: 'Server={{ zabbix_server }}'
    {% endif %}
    - require:
      - pkg: zabbix-install
zabbix-conf2:
  file.replace:
    - name: /etc/zabbix/zabbix_agentd.conf
    - pattern: '^ServerActive=.*'
    {% if "SH1" in grains['id'] %}
    - repl: 'ServerActive={{ sh1b_zabbix_proxy }}'
    {% elif "XM" in grains['id'] %}
    - repl: 'ServerActive={{ zabbix_server }}'
    {% else %}
    - repl: 'ServerActive={{ zabbix_server }}'
    {% endif %}
    - require:
      - pkg: zabbix-install
zabbix-conf3:
  file.replace:
    - name: /etc/zabbix/zabbix_agentd.conf
    - pattern: '^Hostname=.*'
    - repl: "Hostname={{ grains['id'] }}"
    - require:
      - pkg: zabbix-install


zabbix-service:
  service.running:
    - name: zabbix-agent
    - enable: true
    - watch_any:
      - file: zabbix-conf1
      - file: zabbix-conf2
      - file: zabbix-conf3
      - file: zabbix-file3

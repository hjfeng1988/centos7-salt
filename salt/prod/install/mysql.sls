mysql-repo:
  file.managed:
    - name: /etc/yum.repos.d/mysql-community.repo
    - source: salt://install/config/mysql-community.repo

mysql-install:
  pkg.installed:
    - name: mysql-community-server
    - require:
      - file: mysql-repo

mysql-conf:
  file.managed:
    - name: /etc/my.cnf
    - source: salt://install/config/my.cnf
    - require:
      - pkg: mysql-install
  service.running:
    - name: mysqld
    - enable: true
    - watch:
      - file: mysql-conf

mysql-logrotate:
  file.managed:
    - name: /etc/logrotate.d/mysql
    - source: salt://install/config/mysql
    - require:
      - pkg: mysql-install

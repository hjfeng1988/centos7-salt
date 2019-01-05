mysql-repo:
  cmd.run:
    - name: |
        rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
        yum install -y yum-utils
        yum-config-manager --disable mysql80-community
        yum-config-manager --enable mysql57-community
    - unless: rpm --quiet -q mysql80-community-release

mysql-install:
  pkg.installed:
    - name: mysql-community-server

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

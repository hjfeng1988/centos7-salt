mysql-repo:
  cmd.run:
    - name: |
        rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-1.noarch.rpm
        yum install -y yum-utils
        yum-config-manager --disable mysql80-community
        yum-config-manager --enable mysql56-community

mysql-install:
  pkg.installed:
    - name: mysql-community-server

mysql-conf:
  file.managed:
    - name: /etc/my.cnf
    - source: salt://install/config/my.cnf
    - require:
      - pkg: mysql-install
  cmd.run:
    - name: |
        mkdir /data/mysql
        chown -R mysql:mysql /data/mysql
        ln -s /data/mysql /var/lib/mysql
    - require:
      - file: mysql-conf
    - onlyif:
      - test -d /data
      - test ! -d /data/mysql
      - test ! -d /var/lib/mysql
  service.running:
    - name: mysqld
    - enable: true
    - watch:
      - file: mysql-conf
    - require:
      - cmd: mysql-conf

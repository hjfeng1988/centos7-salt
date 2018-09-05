# /etc/sysconfig/selinux 关闭selinux
/etc/sysconfig/selinux:
  file.replace:
    - pattern: SELINUX=enforcing
    - repl: SELINUX=disabled

setenforce:
  cmd.run:
    - name: setenforce 0
    - onlyif: getenforce | grep Enforcing

backup_rsa:
  file.managed:
    - name: /root/.ssh/backup_rsa
    - source: salt://user/sshkey/backup_rsa
    - mode: 600
    - onlyif: test -d /root/.ssh

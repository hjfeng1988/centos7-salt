
/etc/ssh/sshd_config2:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^PermitRootLogin\s+no'
    - repl: 'PermitRootLogin yes'
    - append_if_not_found: true


/etc/ssh/sshd_config3:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^PasswordAuthentication\s+yes'
    - repl: 'PasswordAuthentication no'
    - append_if_not_found: true
  service.running:
    - name: sshd
    - reload: true
    - watch_any:
      - file: /etc/ssh/sshd_config2
      - file: /etc/ssh/sshd_config3


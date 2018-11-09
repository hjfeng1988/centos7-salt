# /etc/ssh/sshd_config 关闭登录过程dns反解析
/etc/ssh/sshd_config1:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^UseDNS\s+yes'
    - repl: 'UseDNS no'
    - append_if_not_found: true

# 禁用root登录
/etc/ssh/sshd_config2:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^PermitRootLogin\s+yes'
    - repl: 'PermitRootLogin no'
    - append_if_not_found: true
    - require:
      - ssh_auth: ssh_key_hjfeng

# 关闭密码登录
/etc/ssh/sshd_config3:
  file.replace:
    - name: /etc/ssh/sshd_config
    - pattern: '^PasswordAuthentication\s+yes'
    - repl: 'PasswordAuthentication no'
    - append_if_not_found: true
    - require:
      - ssh_auth: ssh_key_hjfeng
  service.running:
    - name: sshd
    - reload: true
    - watch_any:
      - file: /etc/ssh/sshd_config1
      - file: /etc/ssh/sshd_config2
      - file: /etc/ssh/sshd_config3

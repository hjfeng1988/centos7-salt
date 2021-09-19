# 添加命令审计
/etc/profile.d/cmd_log.sh:
  file.managed:
    - source: salt://init/config/cmd_log.sh
    - require:
      - file: /etc/profile

# local1日志不记录到messages
/etc/rsyslog.conf1:
  file.replace:
    - name: /etc/rsyslog.conf
    - pattern: '\*.info;mail.none;authpriv.none;cron.none                /var/log/messages'
    - repl: '*.info;mail.none;authpriv.none;cron.none;local1.none    /var/log/messages'
    - require:
      - file: /etc/profile.d/cmd_log.sh

# local1.notice单独记录到cmd.log
/etc/rsyslog.conf2:
  file.append:
    - name: /etc/rsyslog.conf
    - text: "local1.notice                                           /var/log/cmd.log"
    - require:
      - file: /etc/profile.d/cmd_log.sh
  service.running:
    - name: rsyslog
    - watch_any:
      - file: /etc/rsyslog.conf1
      - file: /etc/rsyslog.conf2

# cmd.log日志轮询
/etc/logrotate.d/cmd_log:
  file.managed:
    - source: salt://init/config/cmd_log
    - require:
      - file: /etc/rsyslog.conf

# /etc/rsyslog.d/ignore-systemd-session-slice.conf
/etc/rsyslog.d/ignore-systemd-session-slice.conf:
  file.managed:
    - source: salt://init/config/ignore-systemd-session-slice.conf
  service.running:
    - name: rsyslog
    - watch:
      - file: /etc/rsyslog.d/ignore-systemd-session-slice.conf

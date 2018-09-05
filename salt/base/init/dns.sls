# /etc/resolv.conf
/etc/resolv.conf:
  file.managed:
    - source: salt://init/config/resolv.conf

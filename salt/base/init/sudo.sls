# /etc/sudoers 添加admin、super群组sudo权限
/etc/sudoers.d/custom:
  file.managed:
    - source: salt://init/config/custom

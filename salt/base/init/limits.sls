# 修改nproc
{% if grains['osfinger'] == 'CentOS Linux-7' %}
/etc/security/limits.d/20-nproc.conf:
  file.replace:
    - pattern: '\*          soft    nproc.*'
    - repl: '*          soft    nproc     4096'
{% endif %}

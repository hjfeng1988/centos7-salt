# 修改hostname
{% if grains['osfinger'] == "CentOS Linux-7" %}
hostname:
  cmd.run:
    - name: |
        hostnamectl --static set-hostname {{ grains['id'] }}
        systemctl restart rsyslog
    - unless: hostname | grep "^{{ grains['id'] }}$"
{% endif %}

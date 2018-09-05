# 修改hostname
hostname:
  cmd.run:
    {% if grains['osfinger'] == "CentOS Linux-7" %}
    - name: |
        hostnamectl --static set-hostname {{ grains['id'] }}
        systemctl restart rsyslog
    - unless: hostname | grep "^{{ grains['id'] }}$"
    {% endif %}

# 关闭不常用的服务
{% for service in 'postfix','NetworkManager' %}
disable-{{ service }}:
  service.disabled:
    - name: {{ service }}
{% endfor %}

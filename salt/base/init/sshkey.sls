# /root/.ssh/authorized_keys 添加root密钥
ssh_key_root:
  ssh_auth.present:
    - user: root
    - source: salt://init/config/root.pub

# 添加admin群组
groupadd_admin:
  group.present:
    - name: admin

# 添加super群组
groupadd_super:
  group.present:
    - name: super

# 添加admin成员密钥
{% for user in 'hjfeng','lzl' %}
ssh_key_{{ user }}:
  user.present:
    - name: {{ user }}
    - gid: admin
    - require:
      - group: groupadd_admin
  ssh_auth.present:
    - user: {{ user }}
    - source: salt://init/config/{{ user }}.pub
    - require:
      - file: /etc/sudoers.d/custom
{% endfor %}

# 添加super成员密钥
ssh_key_wykai:
  user.present:
    - name: wykai
    - gid: super
    - require:
      - group: groupadd_super
  ssh_auth.present:
    - user: wykai
    - source: salt://init/config/wykai.pub
    - require:
      - file: /etc/sudoers.d/custom

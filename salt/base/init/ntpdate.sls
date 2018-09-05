# 添加crontab
# 阿里云ecs不添加
ntpdate:
  cron.present:
    - name: ntpdate cn.pool.ntp.org &> /dev/null
    - user: root
    - minute: 10
    - hour: 0
    - require:
      - pkg: yum-list

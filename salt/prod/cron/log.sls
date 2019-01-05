log_rsync:
  cron.present:
    - name: /data/script/log_rsync.sh &> /dev/null
    - user: root
    - minute: 0
    - hour: 4
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'

include:
  - user.backup

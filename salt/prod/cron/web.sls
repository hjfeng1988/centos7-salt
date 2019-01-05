web_bak:
  cron.present:
    - name: /data/script/web_bak.sh &> /dev/null
    - user: root
    - minute: 0
    - hour: 2
    - daymonth: '*'
    - month: '*'
    - dayweek: 7
    - comment: None
web_rsync:
  cron.present:
    - name: /data/script/web_rsync.sh &> /dev/null
    - user: root
    - minute: 0
    - hour: 3
    - daymonth: '*'
    - month: '*'
    - dayweek: 7

include:
  - user.backup
  - cron.log

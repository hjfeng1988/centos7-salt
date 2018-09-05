mysql_bak:
  cron.present:
    - name: /data/script/mysql_bak.sh &> /dev/null
    - user: root
    - minute: 2
    - hour: 2
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'

mysql_rsync:
  cron.present:
    - name: /data/script/mysql_rsync.sh &> /dev/null
    - user: root
    - minute: 3
    - hour: 3
    - daymonth: '*'
    - month: '*'
    - dayweek: '*'

include:
  - user.backup
  - script.mysql

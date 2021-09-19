include:
  - script.base
  - script.log

mysql-script:
  file.recurse:
    - name: /data/script
    - source: salt://script/mysql
    - file_mode: 755
    - onlyif: test -d /data

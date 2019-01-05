include:
  - script.base
  - script.log

mysql-sh:
  file.recurse:
    - name: /data/script
    - source: salt://script/mysql
    - file_mode: 755
    - onlyif: test -d /data/script

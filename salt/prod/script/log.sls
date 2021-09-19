log-script:
  file.recurse:
    - name: /data/script
    - source: salt://script/log
    - file_mode: 755
    - onlyif: test -d /data

base-cmd:
  cmd.run:
    - name: mkdir /data

base-sh:
  file.recurse:
    - name: /data/script
    - source: salt://script/base
    - file_mode: 750
    - onlyif: test -d /data

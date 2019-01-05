base-cmd:
  cmd.run:
    - name: mkdir /data -p
    - unless: test -d /data

base-sh:
  file.recurse:
    - name: /data/script
    - source: salt://script/base
    - file_mode: 750

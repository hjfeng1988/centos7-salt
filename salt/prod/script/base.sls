base-cmd:
  cmd.run:
    - name: mkdir /data -p
    - unless: test -d /data

base-script:
  file.recurse:
    - name: /data/script
    - source: salt://script/base
    - file_mode: 750

nginx-install:
  pkg.installed:
    - name: nginx

nginx-log:
  cmd.run:
    - name: |
        mkdir -p /data/logs/nginx
        chown -R nginx:nginx /data/logs/nginx
        rm -rf /var/log/nginx
        ln -s /data/logs/nginx /var/log/nginx
    - onlyif:
      - test -d /data
      - test ! -L /var/log/nginx
    - require:
      - pkg: nginx-install

nginx-conf:
  file.managed:
    - name: /etc/nginx/nginx.conf
    - source: salt://install/config/nginx.conf
    - require:
      - pkg: nginx-install
  service.running:
    - name: nginx
    - enable: true
    - watch:
      - file: nginx-conf

nginx-logrotate:
  file.managed:
    - name: /etc/logrotate.d/nginx
    - source: salt://install/config/nginx
    - require:
      - pkg: nginx-install

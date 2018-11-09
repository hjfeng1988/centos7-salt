nginx-install:
  pkg.installed:
    - name: nginx

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

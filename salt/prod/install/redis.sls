redis-install:
  pkg.installed:
    - name: redis

redis-install-post1:
  cmd.run:
    - name: |
        mv /var/lib/redis /data
        ln -s /data/redis /var/lib/redis
    - onlyif:
      - test -d /data
      - test ! -L /var/lib/redis
    - require:
      - pkg: redis-install

redis-install-post2:
  cmd.run:
    - name: |
        echo 512 > /proc/sys/net/core/somaxconn
        echo never > /sys/kernel/mm/transparent_hugepage/enabled
        sysctl vm.overcommit_memory=1
        echo "echo 512 >  /proc/sys/net/core/somaxconn" >> /etc/rc.local
        echo "echo never > /sys/kernel/mm/transparent_hugepage/enabled" >> /etc/rc.local
        echo "vm.overcommit_memory = 1" >> /etc/sysctl.conf
        chmod +x /etc/rc.local
    - unless:
      - grep somaxconn /etc/rc.local
      - grep vm.overcommit_memory /etc/sysctl.conf
    - require:
      - pkg: redis-install
redis-confi1:
  file.replace:
    - name: /etc/redis.conf
    - pattern: '^bind.*'
    - repl: 'bind 0.0.0.0'
    - require:
      - pkg: redis-install

redis-confi2:
  file.replace:
    - name: /etc/redis.conf
    - pattern: '^# requirepass.*'
    - repl: 'requirepass xmld0592'
    - require:
      - pkg: redis-install
  service.running:
    - name: redis
    - enable: true
    - watch_any:
      - file: redis-confi1
      - file: redis-confi2

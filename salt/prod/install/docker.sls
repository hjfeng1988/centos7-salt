docker-repo:
  cmd.run:
    - name: |
        yum install -y yum-utils device-mapper-persistent-data lvm2
        yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
        yum makecache fast
        mkdir /etc/docker -p

docker-install:
  pkg.installed:
    - name: docker-ce
    - require:
      - cmd: docker-repo

docker-conf:
  file.append:
    - name: /etc/docker/daemon.json
    - text: |
        {
          "registry-mirrors": ["https://registry.docker-cn.com"]
        }
    - require:
      - pkg: docker-install
  cmd.run:
    - name: systemctl daemon-reload
    - watch:
      - file: /etc/docker/daemon.json
  service.running:
    - name: docker
    - enable: true
    - watch:
      - file: /etc/docker/daemon.json
    - require:
      - pkg: docker-install

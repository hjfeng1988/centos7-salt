1.master配置好/etc/salt/roster

```
[root@salt-master ~]# cat /etc/salt/roster 
host101:
  host: 192.168.1.101
  user: root
  passwd: password

host102:
  host: 192.168.1.102
  user: root
  passwd: password
```

2.安装minion客户端，使用salt-repo-2017.7-1.el7.noarch.rpm，master最好也需要此版本

`salt-ssh -i \* state.sls minion`

3.master接受客户端

`salt-key -a 'host101,host102'`

4.minion环境初始化

`salt \* state.sls init`

5.minion安装软件

`salt host101 state.sls install.jdk saltenv=prod`

master配置信息

```
[root@salt-master ~]# grep -Ev "^$|#" /etc/salt/master 
interface: 0.0.0.0
file_roots:
  base:
    - /srv/salt/base
  prod:
    - /srv/salt/prod
pillar_roots:
  base:
    - /srv/pillar/base
  prod:
    - /srv/pillar/prod
```



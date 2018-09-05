# /etc/hosts
{{ grains['ip4_interfaces']['eth0'][0] }}:
  host.only:
    - hostnames: 
      - {{ grains['id'] }}

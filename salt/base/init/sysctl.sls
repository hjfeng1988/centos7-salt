# /etc/sysctl.conf
/etc/sysctl.conf1:
  file.append:
    - name: /etc/sysctl.conf
    - text: |

        # add by hjfeng
        net.ipv4.tcp_tw_reuse = 1
        net.ipv4.tcp_timestamps = 1

/etc/sysctl.conf2:
  file.replace:
    - name: /etc/sysctl.conf
    - pattern: '^net.ipv4.tcp_max_tw_buckets =.*'
    - repl: 'net.ipv4.tcp_max_tw_buckets = 100000'

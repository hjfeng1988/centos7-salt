yum_update:
  pkg.latest:
    - pkgs:
      - dhcp-libs
      - dhclient
      - dhcp-common
      - bind-utils
      - telnet
      - libxml2

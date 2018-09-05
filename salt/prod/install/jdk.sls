{% set version = '8u161' %}
{% set version2 = '1.8.0_161' %}
jdk-install:
  file.managed:
    - name: /usr/local/src/jdk-{{ version }}-linux-x64.tar.gz
    - source: salt://install/soft/jdk-{{ version }}-linux-x64.tar.gz
  cmd.run:
    - name: |
        cd /usr/local/src
        tar -zxf jdk-{{ version }}-linux-x64.tar.gz
        mv jdk{{ version2 }} /usr/local/jdk
    - unless: test -d /usr/local/jdk

jdk-profile:
  file.managed:
    - name: /etc/profile.d/jdk.sh
    - source: salt://install/config/jdk.sh
    - require:
      - cmd: jdk-install

jdk-securerandom:
  file.replace:
    - name: /usr/local/jdk/jre/lib/security/java.security
    - pattern: 'securerandom.source=file:/dev/random'
    - repl: 'securerandom.source=file:/dev/urandom'
    - require:
      - cmd: jdk-install

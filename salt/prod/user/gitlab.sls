ssh_key_gitlab:
  user.present:
    - name: gitlab
  ssh_auth.present:
    - user: gitlab
    - source: salt://user/sshkey/gitlab.pub


/etc/sudoers.d/gitlab:
  file.append:
    - text: "gitlab        ALL=(ALL)        NOPASSWD: /data/script/ctrl*.sh"

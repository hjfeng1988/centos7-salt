# /etc/profile
/etc/profile:
  file.append:
    - text: 
      - HISTTIMEFORMAT="%F %T "
      - PS1="[\u@\h \[\e[36m\]\w\[\e[0m\]]\\$ "

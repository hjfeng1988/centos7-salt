readonly PROMPT_COMMAND='{ cmd=$(history 1 | { read a b c d; echo "$d"; });msg=$(who am i |awk "{print \$2,\$5}");logger -i -p local1.notice "$msg $USER $PWD # $cmd"; }'

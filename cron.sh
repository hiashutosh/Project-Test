#/bin/bash
sed 
cat >> /etc/cron.d/e2scrub_all << EOF
0 * * * * /ansible/randomize-title.sh
EOF
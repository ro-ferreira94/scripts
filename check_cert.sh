#!/bin/bash
TARGET="webmail.u.inova.com.br";
SCRIPT_RENEW=/root/renew.sh
RECIPIENT="hostmaster@mysite.example.net";
DAYS=95;
echo "checking if SSL expires in less than $DAYS days";
expirationdate=$(date -d"$(su - zimbra -c 'zmcertmgr checkcrtexpiration | grep -i mta | cut -d\= -f2' | awk '{print $1,$2,$4}')" '+%s');
in7days=$(($(date +%s) + (86400*$DAYS)));
if [ $in7days -gt $expirationdate ]; then
#	source "$SCRIPT_RENEW"
        sshpass -f senha ssh -t inova@10.243.214.21 "sudo /bin/mv -f /opt/zimbra/ssl/zimbra/commercial/ /opt/zimbra/ssl/zimbra/commercial_$(date +%d_%m_%y_%s)"
        sshpass -f senha ssh -t inova@10.243.214.40 "sudo /bin/mv -f /opt/zimbra/ssl/zimbra/commercial/ /opt/zimbra/ssl/zimbra/commercial_$(date +%d_%m_%y_%s)"
        sshpass -f senha ssh -t inova@10.243.214.41 "sudo /bin/mv -f /opt/zimbra/ssl/zimbra/commercial/ /opt/zimbra/ssl/zimbra/commercial_$(date +%d_%m_%y_%s)"
        sshpass -f senha scp -r /opt/zimbra/ssl/zimbra/commercial/ inova@10.243.214.21:~
        sshpass -f senha scp -r /opt/zimbra/ssl/zimbra/commercial/ inova@10.243.214.40:~
        sshpass -f senha scp -r /opt/zimbra/ssl/zimbra/commercial/ inova@10.243.214.41:~
        sshpass -f senha ssh inova@10.243.214.21 "sudo /bin/mv -f /home/inova/commercial/ /opt/zimbra/ssl/zimbra/commercial/"
        sshpass -f senha ssh inova@10.243.214.40 "sudo /bin/mv -f /home/inova/commercial/ /opt/zimbra/ssl/zimbra/commercial/"
        sshpass -f senha ssh inova@10.243.214.41 "sudo /bin/mv -f /home/inova/commercial/ /opt/zimbra/ssl/zimbra/commercial/"
        sshpass -f senha ssh inova@10.243.214.21 "sudo /bin/chown -R zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/"
        sshpass -f senha ssh inova@10.243.214.40 "sudo /bin/chown -R zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/"
        sshpass -f senha ssh inova@10.243.214.41 "sudo /bin/chown -R zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/"
        sshpass -f senha ssh inova@10.243.214.21 'sudo su - zimbra -c "/opt/zimbra/bin/zmcertmgr deploycrt comm /opt/zimbra/ssl/zimbra/commercial/commercial.crt /opt/zimbra/ssl/zimbra/commercial/commercial_ca.crt"'
        sshpass -f senha ssh inova@10.243.214.40 'sudo su - zimbra -c "/opt/zimbra/bin/zmcertmgr deploycrt comm /opt/zimbra/ssl/zimbra/commercial/commercial.crt /opt/zimbra/ssl/zimbra/commercial/commercial_ca.crt"'
        sshpass -f senha ssh inova@10.243.214.41 'sudo su - zimbra -c "/opt/zimbra/bin/zmcertmgr deploycrt comm /opt/zimbra/ssl/zimbra/commercial/commercial.crt /opt/zimbra/ssl/zimbra/commercial/commercial_ca.crt"'
        sshpass -f senha ssh inova@10.243.214.21 'sudo su - zimbra -c "zmproxyctl restart"'
        sshpass -f senha ssh inova@10.243.214.40 'sudo su - zimbra -c "zmproxyctl restart"'
        sshpass -f senha ssh inova@10.243.214.41 'sudo su - zimbra -c "zmproxyctl restart"'
	echo "SSL Renovado em todo os proxyes"
else
	echo "Seu certificado esta atualizado e vence em $(date -d @$expirationdate)";
fi;

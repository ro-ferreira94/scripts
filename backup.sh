#!/bin/bash
/opt/zimbra/bin/zmprov gqu slzlbox66.tjma.jus.br | grep -v ldap68 | awk '{print $1}'  > /tmp/contas_backup
CONTAS=$(cat /tmp/backup | sed ':a;N;s/\n/,/g;ta')
/opt/zimbra/bin/zbackup -f $CONTAS

rm -f /tmp/contas_backup

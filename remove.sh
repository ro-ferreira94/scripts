#!/bin/bash
# rm_message.sh user@domain.com subject
# or
# rm_message.sh user@domain.com


if [ -z "$2" ]; then
addr=$1
#### Descomente a linha abaixo para rastrear a mensagem nas caixas postais que estiver no arquivo temp_email
for acct in `cat /opt/zimbra/temp_email` ; do
#### Descomente a linha abaixo para rastrear a mensagem em todas as caixas
#for acct in `zmprov -l gaa | grep -E -v '(^admin@|^spam\..*@|^ham\..*@|^virus-quarantine.*@|^galsync.*@)'|sort` ; do
    echo "Searching $acct"
    for msg in `/opt/zimbra/bin/zmmailbox -z -m "$acct" s -l 999 -t message "from:$addr"|awk '{ if (NR!=1) {print}}' | grep -v -e Id -e "----" -e "^$" | awk '{ print $2 }'`
    do
        #### Descomente a duas linhas abaixo para apagar a mensagem
	#echo "Removing "$msg" from "$acct""
	#/opt/zimbra/bin/zmmailbox -z -m $acct dm $msg
        #### Descomente a duas linhas abaixo para mover a mensagem para a lixeira
	echo "Moving "$msg" from "$acct" to Trash"
	/opt/zimbra/bin/zmmailbox -z -m $acct mm $msg /Trash
    done
done
else
addr=$1
subject=$2
#### Descomente a linha abaixo para rastrear a mensagem nas caixas postais que estiver no arquivo temp_email
for acct in `cat /opt/zimbra/temp_email` ; do
#### Descomente a linha abaixo para rastrear a mensagem em todas as caixas
#for acct in `zmprov -l gaa | grep -E -v '(^admin@|^spam\..*@|^ham\..*@|^virus-quarantine.*@|^galsync.*@)'|sort` ; do
    echo "Searching $acct  for Subject:  $subject"
    for msg in `/opt/zimbra/bin/zmmailbox -z -m "$acct" s -l 999 -t message "from:$addr subject:$subject"|awk '{ if (NR!=1) {print}}' | grep -v -e Id -e "----" -e "^$" | awk '{ print $2 }'`
    do
      #### Descomente a duas linhas abaixo para apagar a mensagem
      #echo "Removing "$msg" from "$acct""
      #/opt/zimbra/bin/zmmailbox -z -m $acct dm $msg
      #### Descomente a duas linhas abaixo para mover a mensagem para a lixeira
      echo "Moving "$msg" from "$acct" to Trash"
      /opt/zimbra/bin/zmmailbox -z -m $acct mm $msg /Trash
    done
done
fi

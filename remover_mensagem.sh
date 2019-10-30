#!/bin/bash
mysql -e "show databases;" | grep -i mboxgroup > /tmp/database

echo 'Assunto da mensagem ?'
read ASS

RESL=`for i in $(cat /tmp/database) ; do mysql -b "$i" -e "select * from mail_item where subject '%$ASS%' ;" ; done > /tmp/mensagem`
QT=`cat /tmp/mensagem | wc -l`
echo -e "\n FORAM ENCONTRADOS $QT MENSAGENS COM O ASSUNTO $ASS \n"

read -p " DESEJA EXCLUIR ESTAS MENSAGENS ? ( responda sim ou nao ) : " ASK

if [ "$ASK" == "sim" ]
then
  for i in $(cat /tmp/database) ; do mysql -b "$i" -e "delete from mail_item where subject '%$ASS%' ;" ; done
  echo -e "\nTODAS AS MENSAGENS COM ESTE ASSUNTO $ASS FORAM EXCLUIDAS\n"
fi

rm -f /tmp/database
rm -f /tmp/mensagem

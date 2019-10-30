#!/bin/bash
MSG=rodrigo.ferreira@inova.net
output="/tmp/lista.txt"
id="/tmp/id_result.txt"
result="/tmp/result.txt"

/opt/zimbra/postfix/sbin/postqueue -p  | egrep "^[A-Z,0-9]" | awk '{print $7}'| sort | uniq -c | sort -n > /tmp/teste.txt

while read linha
do
QUANT=`echo $linha | awk '{ print $1 }'`
MAIL=`echo $linha | awk '{ print $2 }'`
if [ "$QUANT" -gt "5" ]; then
ACCOUNT="Existem "$QUANT" e-mails de "$MAIL" na fila"
fi
done < /tmp/teste.txt
echo $ACCOUNT
echo $ACCOUNT | awk '{print $2}' > /tmp/tot
TOT=$(cat /tmp/tot)
if [ "$TOT" -gt "200" ]; then
/opt/zimbra/postfix/sbin/postqueue -p |grep -i $MAIL |  awk '{print $1}' > /tmp/id.txt
id_message=$(cat /tmp/id.txt | sed -n "5p")
/opt/zimbra/postfix/sbin/postcat -q $id_message > /tmp/id_result.txt
su - zimbra -c "/opt/zimbra/bin/zmprov ma $MAIL zimbraAccountStatus closed zimbraPasswordMustChange TRUE zimbraPasswordEnforceHistory 10"
/opt/zimbra/postfix/sbin/postqueue -p | grep -i "$MAIL"  -B2 | awk '{ print $1 }' | cut -d\* -f1  | /opt/zimbra/postfix/sbin/postsuper -d -
echo -e "\nForam removidas $TOT do endereço $MAIL \n" > /tmp/lista.txt
/opt/zimbra/postfix/sbin/postqueue -p  | egrep "^[A-Z,0-9]" | awk '{print $7}'| sort | uniq -c | sort -n >> /tmp/lista.txt

(
echo "ehlo inovasuporte.xsp.com.br"
sleep 1
echo "auth login"
sleep 1
echo 'Y29udGFzQGlub3Zhc3Vwb3J0ZS54c3AuY29tLmJy'
echo 'SW5vdmFAMjAxNg=='
sleep 1
echo 'mail from: contas@inovasuporte.xsp.com.br'
sleep 1
echo "rcpt to: $MSG"
sleep 1
echo "data"
sleep 1
echo "MIME-Version: 1.0"
sleep 1
echo 'FROM: <contas@inovasuporte.xsp.com.br>'
sleep 1
echo "TO: <$MSG>"
sleep 1
echo -e "SUBJECT: conta bloqueada $MAIL \n"
sleep 1
sleep 1
cat $id
echo '.'
sleep 1
echo "quit"
) | telnet r-sv5 25

(
echo "ehlo inovasuporte.xsp.com.br"
sleep 1
echo "auth login"
sleep 1
echo 'Y29udGFzQGlub3Zhc3Vwb3J0ZS54c3AuY29tLmJy'
echo 'SW5vdmFAMjAxNg=='
sleep 1
echo 'mail from: contas@inovasuporte.xsp.com.br'
sleep 1
echo "rcpt to: $MSG"
sleep 1
echo "data"
sleep 1
echo "MIME-Version: 1.0"
sleep 1
echo 'FROM: <contas@inovasuporte.xsp.com.br>'
sleep 1
echo "TO: <$MSG>"
sleep 1
echo -e "SUBJECT: Lista fila \n"
sleep 1
sleep 1
cat $output
echo '.'
sleep 1
echo "quit"
) | telnet r-sv5 25

elif [ "$TOT" -le "100" ]; then
echo -e "\n total de mensagens insuficiente \n"
(
echo "ehlo inovasuporte.xsp.com.br"
sleep 1
echo "auth login"
sleep 1
echo 'Y29udGFzQGlub3Zhc3Vwb3J0ZS54c3AuY29tLmJy'
echo 'SW5vdmFAMjAxNg=='
sleep 1
echo 'mail from: contas@inovasuporte.xsp.com.br'
sleep 1
echo "rcpt to: $MSG"
sleep 1
echo "data"
sleep 1
echo "MIME-Version: 1.0"
sleep 1
echo 'FROM: <contas@inovasuporte.xsp.com.br>'
sleep 1
echo "TO: <$MSG>"
sleep 1
echo -e "SUBJECT: Fila \n"
sleep 1
sleep 1
cat $result
echo '.'
sleep 1
echo "quit"
) | telnet r-sv5 25
fi

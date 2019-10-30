#!/bin/bash
MSG=rodrigo.ferreira@inova.net
output="/tmp/lista.txt"
id="/tmp/id_result.txt"
result="/tmp/result.txt"

/usr/sbin/postqueue -p  | egrep "^[A-Z,0-9]" | awk '{print $7}'| sort | uniq -c | sort -n > /tmp/lista.txt

while read linha
do
QUANT=`echo $linha | awk '{ print $1 }'`
MAIL=`echo $linha | awk '{ print $2 }'`
if [ "$QUANT" -gt "50" ]; then
echo "Existem "$QUANT" e-mails de "$MAIL "na fila" >> /tmp/fila.txt
cat /tmp/fila.txt | awk '{print $2}' > /tmp/qto
fi
done < /tmp/lista.txt
cat /tmp/fila.txt | awk '{print $5}' > /tmp/tot
cat /tmp/fila.txt | sed 's/Existem /Foram removidas /g' > /tmp/qto
TOT=$(cat /tmp/tot)
QTO=$(cat /tmp/qto)

if [ "$QUANT" -gt "500" ]; then
for i in $(cat /tmp/tot | grep -v "admin") ; do /usr/sbin/postqueue -p ||grep -i "$i"| awk '{print $1}' | grep -v '*' ; done > /tmp/id.txt
#id_message=$(cat /tmp/id.txt | sed -n "5p")
for i in $(cat /tmp/id.txt | grep -v '*') ; do /usr/sbin/postcat -q "$i" ; done >> /tmp/id_result.txt
#su - zimbra -c "/opt/zimbra/bin/zmprov ma $MAIL zimbraAccountStatus closed zimbraPasswordMustChange TRUE zimbraPasswordEnforceHistory 10"
for i in $(cat /tmp/tot) ; do /usr/sbin/postqueue -p | grep -i "$i"  -B2 | awk '{ print $1 }' | cut -d\* -f1  | /usr/sbin/postsuper -d - > /tmp/lista.txt ;  done
/usr/sbin/postqueue -p  | egrep "^[A-Z,0-9]" | awk '{print $7}'| sort | uniq -c | sort -n >> /tmp/lista.txt
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
) | telnet mxcorp3 25

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
cat /tmp/qto
echo -e "\n"
cat $output
echo '.'
sleep 1
echo "quit"
) | telnet mxcorp3 25

elif [ "$QUANT" -le "400" ]; then
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
) | telnet mxcorp3 25
fi
rm -f /tmp/lista.txt

#!/bin/bash

## SCRIPT INSTALATION CERTIFICATE LET'S ENCRYPT ##

CHAIN="/opt/zimbra/chain.txt"
echo "Parando o Zimbra" ; sleep 2
su - zimbra -c "zmproxyctl stop ; zmmailboxdctl stop"
echo "Zimbra Parado"
echo "Entrando no diretorio do Lets ( /root/letsencrypt/ )"
cd /root/letsencrypt/
echo "Gerando a lista de dominios"
zdomains=$(for domain in $(su - zimbra -c "zmprov gad"); do echo -n "-d webmail.${domain} " ; done)
echo "Pronto, Gerando certificados"
./letsencrypt-auto certonly --standalone $zdomains
echo "Entrando no diretorio do certificado"
cd /etc/letsencrypt/archive/inframbox01.a.inova.com.br
echo "Setando as permissões necessarias"
chown zimbra:zimbra *
echo "Renomeando a chave privada"
mv privkey1.pem commercial.key
echo "Substituindo a chave privada"
mv /opt/zimbra/ssl/zimbra/commercial/commercial.key /opt/zimbra/ssl/zimbra/commercial/commercial.key.old
echo "movento a chave privada para o diretorio commercial"
mv commercial.key /opt/zimbra/ssl/zimbra/commercial/
echo "Instalando a chain no arquivo chain.pem"
cat $CHAIN >> chain1.pem
su - zimbra -c "zmcertmgr verifycrt comm /opt/zimbra/ssl/zimbra/commercial/commercial.key cert1.pem chain1.pem"
su - zimbra -c "zmcertmgr deploycrt comm /etc/letsencrypt/archive/inframbox01.a.inova.com.br/cert1.pem /etc/letsencrypt/archive/inframbox01.a.inova.com.br/chain1.pem"
su - zimbra -c "zmmailboxdctl start ; zmproxyctl start"
cp -rf /etc/letsencrypt/archive/inframbox01.a.inova.com.br/ /opt/zimbra/
rm -rf /etc/letsencrypt/archive/inframbox01.a.inova.com.br/
echo "CERTIFICADO INSTALADO"

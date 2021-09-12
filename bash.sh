#!/bin/bash

apt-get install -y mpack
#source /root/scripts/mxhero_attach.sh
#source /root/scripts/mxhero_copy.sh
source /root/scripts/mxhero_bundle.sh

rm -f /tmp/logs_mxhero_hsaomxhero.zip
zip -r /tmp/logs_mxhero_hsaomxhero.zip /tmp/lista_regra/ > /dev/null 2>&1
chmod 777 /tmp/logs_mxhero_hsaomxhero.zip
CLIENTE="HSAOMXHERO"
DATASAIDA=`date +"%Y-%m"`
SAIDA="/tmp/logs_mxhero_hsaomxhero.zip"

echo "Mxhero Report - $CLIENTE" |  mpack -s "Mxhero Report - $CLIENTE - $DATASAIDA" -a $SAIDA rodrigo.ferreira@inova.net,luiz.nascimento@inova.net,katia.venancio@inova.net
#echo "Mxhero Report - $CLIENTE" | mutt  -s "Mxhero Report - $CLIENTE - $DATASAIDA" -a $SAIDA rodrigo.ferreira@inova.net

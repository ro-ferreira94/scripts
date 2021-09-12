#!/bin/bash
#==========Script para monitorar a nomenclatura de cos do servidor==========#


/opt/zimbra/bin/zmprov gac -v | grep -i '# name' > /tmp/COS
QT=$(cat /tmp/COS |wc -l)

if [ $QT -eq 7 ];
then
	echo "COS - OK"
	exit 0
else
	echo "CRITICO - COS FORA DO PADRAO"
	exit 2
fi

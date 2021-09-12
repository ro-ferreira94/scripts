#!/bin/bash

#imysql -uroot -p mxhero -e "select features_rules.domain_id,features.component from features_rules inner join features ON features_rules.feature_id = features.id where component = 'org.mxhero.feature.attachmentblock' and domain_id IS NOT NULL;"

#rm -rf /tmp/lista_regra
mkdir -p /tmp/lista_regra > /dev/null 2>&1

mysql -uroot -pmxhero mxhero -e "select id,domain_id from features_rules where feature_id = 1 and domain_id is not null;" > /tmp/lista_regra/dominio_attach.txt

FILE_ATTACH=$(cat /tmp/lista_regra/dominio_attach.txt | egrep -v "^id|^domain_id" | awk '{print $1}')

FILE_NAME_ATTACH=$(cat /tmp/lista_regra/dominio_attach.txt | egrep -v "^id|^domain_id" |awk '{print $2}')

fun()
{
	set $FILE_NAME_ATTACH
	for i in $FILE_ATTACH
do
	mysql -uroot -pmxhero mxhero -e "select property_value from features_rules_properties where rule_id = $i and property_key = 'file.extension';" >> /tmp/lista_regra/attach_$1.txt
	shift
done
}
fun

sed -nri 'G;/^([^\n]+\n)([^\n]+\n)*\1/!{P;h}' /tmp/lista_regra/attach_*.txt
sed -i 's/property_value/Extensoes Bloqueio de anexo/g' /tmp/lista_regra/attach_*.txt
rm -f /tmp/lista_regra/dominio_attach.txt
chmod 777 /tmp/lista_regra/attach_*.txt
#zip -r /tmp/regras_mxhero_sp3.zip /tmp/lista_regra/* > /dev/null 2>&1
#chmod 777 /tmp/regras_mxhero_sp3.zip

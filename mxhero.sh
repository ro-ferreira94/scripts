#!/bin/bash

#imysql -uroot -p mxhero -e "select features_rules.domain_id,features.component from features_rules inner join features ON features_rules.feature_id = features.id where component = 'org.mxhero.feature.attachmentblock' and domain_id IS NOT NULL;"

#rm -rf /tmp/lista_regra
mkdir -p /tmp/lista_regra > /dev/null 2>&1

mysql -uroot -pmxhero mxhero -e "select id,domain_id from features_rules where feature_id = 16 and domain_id is not null;" > /tmp/lista_regra/dominio_blacklist.txt
mysql -uroot -pmxhero mxhero -e "select id,domain_id from features_rules where feature_id = 15 and domain_id is not null;" > /tmp/lista_regra/dominio_whitelist.txt

FILE_WHITE=$(cat /tmp/lista_regra/dominio_whitelist.txt | egrep -v "^id|^domain_id" | awk '{print $1}')

FILE_NAME_WHITE=$(cat /tmp/lista_regra/dominio_whitelist.txt | egrep -v "^id|^domain_id" |awk '{print $2}')

FILE_BLACK=$(cat /tmp/lista_regra/dominio_blacklist.txt | egrep -v "^id|^domain_id" | awk '{print $1}')

FILE_NAME_BLACK=$(cat /tmp/lista_regra/dominio_blacklist.txt | egrep -v "^id|^domain_id" |awk '{print $2}')

fun()
{
	set $FILE_NAME_WHITE
	for i in $FILE_WHITE
do
	mysql -uroot -pmxhero mxhero -e "select property_value from features_rules_properties where rule_id = $i and property_value like '%@%';" >> /tmp/lista_regra/whitelist_$1.txt
	shift
done
}
fun

fun()
{
        set $FILE_NAME_BLACK
        for a in $FILE_BLACK
do
	mysql -uroot -pmxhero mxhero -e "select property_value from features_rules_properties where rule_id = $a and property_value like '%@%';" >> /tmp/lista_regra/blacklist_$1.txt
	shift
done
}
fun
sed -nri 'G;/^([^\n]+\n)([^\n]+\n)*\1/!{P;h}' /tmp/lista_regra/whitelist_*.txt
sed -nri 'G;/^([^\n]+\n)([^\n]+\n)*\1/!{P;h}' /tmp/lista_regra/blacklist_*.txt
sed -i 's/property_value/Dominios e contas Whitelist/g' /tmp/lista_regra/whitelist_*.txt
sed -i 's/property_value/Dominios e contas Blacklist/g' /tmp/lista_regra/blacklist_*.txt
rm -f /tmp/lista_regra/dominio_whitelist.txt
rm -f /tmp/lista_regra/dominio_blacklist.txt
chmod 777 /tmp/lista_regra/whitelist_*.txt
chmod 777 /tmp/lista_regra/blacklist_*.txt
zip -r /tmp/regras_mxhero_sp3.zip /tmp/lista_regra/* > /dev/null 2>&1
chmod 777 /tmp/regras_mxhero_sp3.zip

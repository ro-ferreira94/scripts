#!/bin/bash

#imysql -uroot -p mxhero -e "select features_rules.domain_id,features.component from features_rules inner join features ON features_rules.feature_id = features.id where component = 'org.mxhero.feature.attachmentblock' and domain_id IS NOT NULL;"

rm -rf /tmp/lista_regra
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
#!/bin/bash

#rm -rf /tmp/lista_regra

mysql -uroot -pmxhero mxhero -e "select id,domain_id from features_rules where feature_id = 6 and domain_id is not null;" > /tmp/lista_regra/dominio_copy.txt

FILE_COPY=$(cat /tmp/lista_regra/dominio_copy.txt | egrep -v "^id|^domain_id" | awk '{print $1}')

FILE_NAME_COPY=$(cat /tmp/lista_regra/dominio_copy.txt | egrep -v "^id|^domain_id" |awk '{print $2}')

fun()
{
	set $FILE_NAME_COPY
	for i in $FILE_COPY
do
	mysql -uroot -pmxhero mxhero -e "select fr.domain_id as dominio, f1.free_value as froom, f2.free_value as too, fp.property_value as Conta from features_rules fr inner join ( select free_value,id from features_rules_directions ) as f1 on fr.from_direction_id = f1.id inner join ( select free_value, id from features_rules_directions ) f2 on fr.to_direction_id = f2.id inner join (select id,rule_id,property_key,property_value from features_rules_properties where rule_id = '$i' and property_key = 'email.value') fp on fr.id = fp.rule_id;" >> /tmp/lista_regra/copy_$1.txt
	shift
done
}
fun

sed -nri 'G;/^([^\n]+\n)([^\n]+\n)*\1/!{P;h}' /tmp/lista_regra/copy_*.txt
sed -i 's/too/to/g' /tmp/lista_regra/copy_*.txt
sed -i 's/froom/from/g' /tmp/lista_regra/copy_*.txt
rm -f /tmp/lista_regra/dominio_copy.txt
chmod 777 /tmp/lista_regra/copy_*.txt
#!/bin/bash

#imysql -uroot -p mxhero -e "select features_rules.domain_id,features.component from features_rules inner join features ON features_rules.feature_id = features.id where component = 'org.mxhero.feature.attachmentblock' and domain_id IS NOT NULL;"

#rm -rf /tmp/lista_regra

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

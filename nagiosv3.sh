#!/bin/bash
#################################################################
#                                                               #
#               Nagios-plugins for RHEL 7                       #
#                                                               #
#################################################################
#								#
#		By: Felipe Maeda - INOVA			#
#								#
#################################################################

# Configurações
TIME=5
HOST=$(hostname)
IP=$(ifconfig | awk 'NR>=2 && NR<=2' | awk '{ print $2 }' | cut -d: -f2)
DIR_CHECK_MK=/etc/check_mk/
FILE_CHECK_MK_AGENT=/usr/bin/check_mk_agent
FILE_CHECK_MK_MRPE=/etc/check_mk/mrpe.cfg
FILE_CHECK_MK_XINETD=/etc/xinetd.d/check_mk
HOST_IMPORT_MKS=192.168.45.101 # Zimbrambox01

# Limpando arquivos de diretórios
rm -rf $FILE_CHECK_MK_MRPE;
rm -rf $FILE_CHECK_MK_XINETD;
rm -rf /tmp/temp_mrpe.txt;
rm -rf /tmp/temp_xinetd.txt;
rm -rf /tmp/temp_install.txt
rm -rf /tmp/temp_no_install.txt

# Verificando atualizações
yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install nrpe
yum check-update;
yum clean metadata;

echo "Instalizando bibliotecas essenciais.";
echo "epel-release nrpe nagios-common nagios-plugins nagios-plugins-mailq nagios-plugins-hpjd nagios-plugins-users nagios-plugins-ssh nagios-plugins-rpc nagios-plugins-mysql nagios-plugins-dhcp nagios-plugins-ntp-perl nagios-plugins-mrtg nagios-plugins-load nagios-plugins-game nagios-plugins-perl nagios-plugins-procs nagios-plugins-sensors nagios-plugins nagios-plugins-ping nagios-plugins-mrtgtraf nagios-plugins-log nagios-plugins-tcp nagios-plugins-dns nagios-plugins-cluster nagios-plugins-ldap nagios-plugins-oracle nagios-plugins-all nagios-plugins-file_age nagios-plugins-real nagios-plugins-by_ssh nagios-plugins-ircd nagios-plugins-pgsql nagios-plugins-nt nagios-plugins-flexlm nagios-plugins-nwstat nagios-plugins-snmp nagios-plugins-breeze nagios-plugins-icmp nagios-plugins-http nagios-plugins-ups nagios-plugins-disk nagios-plugins-swap nagios-plugins-dummy nagios-plugins-nagios nagios-plugins-dig nagios-plugins nagios-plugins-ntp nagios-plugins-smtp nagios-plugins-ide_smart nagios-plugins-disk_smb nagios-plugins-wave nagios-plugins-overcr xinetd" >> /tmp/temp_install.txt;
rpm -qa | egrep "nagios|xinetd|epel-release" | cut -d1 -f1 | cut -d2 -f1 | cut -d3 -f1 | cut -d4 -f1 | cut -d0 -f1 | sed "s/-$//g" | paste -sd\| >> /tmp/temp_no_install.txt

for i in $(cat /tmp/temp_install.txt); do yum install $(echo $i | grep -v $(cat /tmp/temp_no_install.txt)) -y ; done

cat <<EOF >>/tmp/temp_xinetd.txt
service check_mk
{
        type           = UNLISTED
        port           = 6556
        socket_type    = stream
        protocol       = tcp
        wait           = no
        user           = root
        server         = /usr/bin/check_mk_agent

        # If you use fully redundant monitoring and poll the client
        # from more then one monitoring servers in parallel you might
        # want to use the agent cache wrapper:
        #server         = /usr/bin/check_mk_caching_agent > /tmp/log 2>&1"

        # configure the IP address(es) of your Nagios server here:
        #only_from      = 127.0.0.1 192.168.10.0/24 192.168.25.0/24 192.168.26.0/24 192.168.26.0/24 192.168.27.0/24

        # Don't be too verbose. Don't log every check. This might be
        # commented out for debugging. If this option is commented out
        # the default options will be used for this service.
        log_on_success =

        disable        = no
}
EOF

# Configurando xinetd
rm -rf $FILE_CHECK_MK_XINETD;
if [ -e $FILE_CHECK_MK_XINETD ]; then
	echo "Arquivo $FILE_CHECK_MK_XINETD existe. Validar configuração manualmente.";
else
	cat /tmp/temp_xinetd.txt >> $FILE_CHECK_MK_XINETD;
fi;

# Reiniciando serviço xinetd
systemctl restart xinetd;

# Escrevendo arquivo de configuração Check_mk (mrpe.cfg)
cat <<EOF >>/tmp/temp_mrpe.txt
check_imap_login /usr/lib/nagios/plugins/check_imap_login -u cmk@$HOST -p pae9Chei -H 0.0.0.0
check_pop3_login /usr/lib/nagios/plugins/check_pop_login -u cmk@$HOST -p pae9Chei -H 0.0.0.0
check_cos       /usr/lib/nagios/plugins/check_cos.sh
check_disk_/    /usr/lib64/nagios/plugins/check_disk -w 80 -c 90 -p /
$(for i in $(df -h | grep zimbra | awk '{ print $6 }'); do echo "check_disk_$i    /usr/lib64/nagios/plugins/check_disk -w 80 -c 90 -p $i"; done)
check_ssl /usr/lib64/nagios/plugins/check_http --sni -H '$IP' -C 15,7
check_backup_smartscan   /usr/lib/nagios/plugins/check_backup_smartscan.sh
EOF

if [ -e $FILE_CHECK_MK_MRPE ]; then
        echo "Arquivo $FILE_CHECK_MK_MRPE existe. Realizar configuração manualmente ou excluir arquivo.";
else
        cat /tmp/temp_mrpe.txt >> $FILE_CHECK_MK_MRPE;
fi;


mkdir -p /usr/lib/nagios/plugins/;
echo "Digite a senha root:"
scp root@$HOST_IMPORT_MKS:/usr/lib/nagios/plugins/* /usr/lib/nagios/plugins;

echo "Verifique se a monitoração está funcionando corretamente:"
check_mk_agent | tail -n20


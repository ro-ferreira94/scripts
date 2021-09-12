#!/bin/bash
USER=zimbra

#BACKUP SSL

for i in {131..136} ; do sshpass -p '!n0v@789!' ssh -t inova@10.243.213.$i 'sudo tar -cvf /opt/zimbra/backup/zimbra_$(date +%d_%m_%y).tgz /opt/zimbra/ssl/letsencrypt/' ; done
for i in {131..136} ; do sshpass -p '!n0v@789!' ssh -t inova@10.243.213.$i 'sudo rm -f /opt/zimbra/ssl/letsencrypt/*' ; done

for i in 20 21 40 41 ; do sshpass -p '!n0v@789!' ssh -t inova@10.243.214.$i 'sudo tar -cvf /opt/zimbra/backup/zimbra_$(date +%d_%m_%y).tgz /opt/zimbra/ssl/letsencrypt/' ; done
for i in 20 21 40 41 ; do sshpass -p '!n0v@789!' ssh -t inova@10.243.214.$i 'sudo rm -f /opt/zimbra/ssl/letsencrypt/*' ; done

sshpass -p '!n0v@789!' ssh -t inova@10.243.213.36 'sudo tar -cvf /opt/zimbra/backup/zimbra_$(date +%d_%m_%y).tgz /opt/zimbra/ssl/letsencrypt/'
sshpass -p '!n0v@789!' ssh -t inova@10.243.213.36 'sudo rm -f /opt/zimbra/ssl/letsencrypt/*'

#BACKUP COMMERCIAL

for i in {131..136} ; do sshpass -p '!n0v@789!' ssh -t inova@10.243.213.$i 'sudo tar -cvf /opt/zimbra/backup/commercial_$(date +%d_%m_%y).tgz /opt/zimbra/ssl/zimbra/commercial/' ; done

for i in 20 21 40 41  ; do sshpass -p '!n0v@789!' ssh -t inova@10.243.214.$i 'sudo tar -cvf /opt/zimbra/backup/commercial_$(date +%d_%m_%y).tgz /opt/zimbra/ssl/zimbra/commercial/' ; done

sshpass -p '!n0v@789!' ssh -t inova@10.243.213.36 'sudo tar -cvf /opt/zimbra/backup/commercial_$(date +%d_%m_%y).tgz /opt/zimbra/ssl/zimbra/commercial/'

# acme renovacao

.acme.sh/acme.sh --issue --force --standalone --local-address 10.243.214.9 --httpport 81 -d aderes.correio.es.gov.br -d agerh.correio.es.gov.br -d ape.correio.es.gov.br -d arsp.correio.es.gov.br -d autodiscover.prodest.es.gov.br -d bombeiros.correio.es.gov.br -d casacivil.correio.es.gov.br -d casamilitar.correio.es.gov.br -d ceasa.correio.es.gov.br -d ceturb.correio.es.gov.br -d coes.correio.es.gov.br -d der.correio.es.gov.br -d es.correio.es.gov.br -d esesp.correio.es.gov.br -d facafacil.correio.es.gov.br -d fames.correio.es.gov.br -d fapes.correio.es.gov.br -d iases.correio.es.gov.br -d idaf.correio.es.gov.br -d iema.correio.es.gov.br -d ijsn.correio.es.gov.br -d imap.correio.es.gov.br -d incaper.correio.es.gov.br -d ipajm.correio.es.gov.br -d ipem.correio.es.gov.br -d jucees.correio.es.gov.br -d pge.correio.es.gov.br -d pop.correio.es.gov.br -d prefeitura.correio.es.gov.br -d preves.correio.es.gov.br -d procon.correio.es.gov.br -d prodest.correio.es.gov.br -d rtv.correio.es.gov.br -d saude.correio.es.gov.br -d seag.correio.es.gov.br -d seama.correio.es.gov.br -d secom.correio.es.gov.br -d secont.correio.es.gov.br -d secti.correio.es.gov.br -d secult.correio.es.gov.br -d sedes.correio.es.gov.br -d sedh.correio.es.gov.br -d sedurb.correio.es.gov.br -d seg.correio.es.gov.br -d seger.correio.es.gov.br -d sejus.correio.es.gov.br -d semobi.correio.es.gov.br -d sep.correio.es.gov.br -d sesp.correio.es.gov.br -d sesport.correio.es.gov.br -d setades.correio.es.gov.br -d setur.correio.es.gov.br -d sine.correio.es.gov.br -d smtp.correio.es.gov.br -d vice.correio.es.gov.br

#renew command

cd /root/.acme.sh/aderes.correio.es.gov.br/ && \
echo "-----BEGIN CERTIFICATE-----
MIIDSjCCAjKgAwIBAgIQRK+wgNajJ7qJMDmGLvhAazANBgkqhkiG9w0BAQUFADA/
MSQwIgYDVQQKExtEaWdpdGFsIFNpZ25hdHVyZSBUcnVzdCBDby4xFzAVBgNVBAMT
DkRTVCBSb290IENBIFgzMB4XDTAwMDkzMDIxMTIxOVoXDTIxMDkzMDE0MDExNVow
PzEkMCIGA1UEChMbRGlnaXRhbCBTaWduYXR1cmUgVHJ1c3QgQ28uMRcwFQYDVQQD
Ew5EU1QgUm9vdCBDQSBYMzCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
AN+v6ZdQCINXtMxiZfaQguzH0yxrMMpb7NnDfcdAwRgUi+DoM3ZJKuM/IUmTrE4O
rz5Iy2Xu/NMhD2XSKtkyj4zl93ewEnu1lcCJo6m67XMuegwGMoOifooUMM0RoOEq
OLl5CjH9UL2AZd+3UWODyOKIYepLYYHsUmu5ouJLGiifSKOeDNoJjj4XLh7dIN9b
xiqKqy69cK3FCxolkHRyxXtqqzTWMIn/5WgTe1QLyNau7Fqckh49ZLOMxt+/yUFw
7BZy1SbsOFU5Q9D8/RhcQPGX69Wam40dutolucbY38EVAjqr2m7xPi71XAicPNaD
aeQQmxkqtilX4+U9m5/wAl0CAwEAAaNCMEAwDwYDVR0TAQH/BAUwAwEB/zAOBgNV
HQ8BAf8EBAMCAQYwHQYDVR0OBBYEFMSnsaR7LHH62+FLkHX/xBVghYkQMA0GCSqG
SIb3DQEBBQUAA4IBAQCjGiybFwBcqR7uKGY3Or+Dxz9LwwmglSBd49lZRNI+DT69
ikugdB/OEIKcdBodfpga3csTS7MgROSR6cz8faXbauX+5v3gTt23ADq1cEmv8uXr
AvHRAosZy5Q6XkjEGB5YGV8eAlrwDPGxrancWYaLbumR9YbK+rlmM6pZW87ipxZz
R8srzJmwN0jP41ZL9c8PDHIyh8bwRLtTcm1D9SZImlJnt1ir/md2cXjbDaJWFBM5
JDGFoqgCWjBH4d1QB7wCCZAA62RjYJsWvIjJEubSfZGL+T0yjWW06XyxV3bqxbYo
Ob8VZRzI9neWagqNdwvYkQsEjgfbKbYK7p2CNTUQ
-----END CERTIFICATE-----" >> fullchain.cer

#Copia dos arquivos

for i in {131..136} ; do
  sshpass -p '!n0v@789!' scp aderes.correio.es.gov.br.cer aderes.correio.es.gov.br.key fullchain.cer inova@10.243.213.$i:/opt/zimbra/ssl/letsencrypt/
  sshpass -p '!n0v@789!' ssh -t inova@10.243.213.$i 'sudo chown zimbra:zimbra /opt/zimbra/ssl/letsencrypt/*'
  sshpass -p '!n0v@789!' ssh -t inova@10.243.213.$i 'sudo mv /opt/zimbra/ssl/zimbra/commercial/commercial.key /opt/zimbra/ssl/zimbra/commercial/commercial.key.old'
  sshpass -p '!n0v@789!' ssh -t inova@10.243.213.$i 'sudo cp /opt/zimbra/ssl/letsencrypt/aderes.correio.es.gov.br.key /opt/zimbra/ssl/zimbra/commercial/commercial.key ; sudo chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/commercial.key'
done

for i in 20 21 40 41 ; do
  sshpass -p '!n0v@789!' scp aderes.correio.es.gov.br.cer aderes.correio.es.gov.br.key fullchain.cer inova@10.243.214.$i:/opt/zimbra/ssl/letsencrypt/
  sshpass -p '!n0v@789!' ssh -t inova@10.243.214.$i 'sudo chown zimbra:zimbra /opt/zimbra/ssl/letsencrypt/*'
  sshpass -p '!n0v@789!' ssh -t inova@10.243.214.$i 'sudo mv /opt/zimbra/ssl/zimbra/commercial/commercial.key /opt/zimbra/ssl/zimbra/commercial/commercial.key.old'
  sshpass -p '!n0v@789!' ssh -t inova@10.243.214.$i 'sudo cp /opt/zimbra/ssl/letsencrypt/aderes.correio.es.gov.br.key /opt/zimbra/ssl/zimbra/commercial/commercial.key ; sudo chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/commercial.key'
done

sshpass -p '!n0v@789!' scp aderes.correio.es.gov.br.cer aderes.correio.es.gov.br.key fullchain.cer inova@10.243.213.36:/opt/zimbra/ssl/letsencrypt/
sshpass -p '!n0v@789!' ssh -t inova@10.243.213.36 'sudo chown zimbra:zimbra /opt/zimbra/ssl/letsencrypt/*'
sshpass -p '!n0v@789!' ssh -t inova@10.243.213.36 'sudo mv /opt/zimbra/ssl/zimbra/commercial/commercial.key /opt/zimbra/ssl/zimbra/commercial/commercial.key.old'
sshpass -p '!n0v@789!' ssh -t inova@10.243.213.36 'sudo cp /opt/zimbra/ssl/letsencrypt/aderes.correio.es.gov.br.key /opt/zimbra/ssl/zimbra/commercial/commercial.key ; sudo chown zimbra:zimbra /opt/zimbra/ssl/zimbra/commercial/commercial.key'

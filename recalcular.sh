#!/bin/bash/
/opt/zimbra/bin/zmprov -l gaa tjma.jus.br > /tmp/contas_rmc
CONTAS=$(cat /tmp/contas_rmc | sed 's/^/rmc /g')
/opt/zimbra/bin/zmprov -f $CONTAS

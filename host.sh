#!/bin/bash

/usr/bin/host webmail.4infra.com.br > /tmp/hosts
host="/tmp/hosts"
if echo "$host" | egrep '3.210.48.12'
then
  echo -e "\nEste apontamento responde para o servidor"
else
  echo -e "\n não corresponde"
fi


#!/usr/bin/env bash

INT="$1"
WD="$2"
SERVICES="$3"
RHOST="$4"
#Lookup ports for this service
SERVICEPORTS=$(grep $SERVICES ../services_ip.txt | cut -d ";" -f 2)

cd $WD
for SCRIPTS in $(cat ../nse_$SERVICES.txt); do
nmap -e $INT --script $SCRIPTS $RHOST | tee --append $WD/$RHOST/nmap_nse_$SERVICES.txt;
done
exit

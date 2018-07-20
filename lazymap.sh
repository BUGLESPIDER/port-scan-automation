#!/usr/bin/env bash

# Original LazyMap release notes:

# LazyMap
# Daniel Compton
# www.commonexploits.com
# contact@commexploits.com
# Twitter = @commonexploits
# 19/12/2012
# Tested on Bactrack 5 only.

# Import info - read first!

# Nmap Lazy Script - For Internal Inf Testing. tested only on BT5 gnome. Scans should launch 4x terminals at once, may only work on BT5!
# 
# For the auto creation of a custom Nessus policy - export and place one policy file within the same directory as the script with any filename or extension - it will find it use this as a template.
# For Nessus template use ensure the following options are set UDP SCAN=ON, SNMP SCAN=ON, SYN SCAN=ON,  PING HOST=OFF, TCP SCAN=OFF - the script will enable safe checks and consider unscanned ports as closed - double check before scanning.


#####################################################################################
# Released as open source by NCC Group Plc - http://www.nccgroup.com/

# Developed by Daniel Compton, daniel dot compton at nccgroup dot com

# https://github.com/nccgroup/vlan-hopping

#Released under AGPL see LICENSE for more information

######################################################################################


#### FORK NOTES:

# This BUGLESPIDER fork is a heavily modified version for running enumeration:
# nmap
# nmap NSEs
# nikto
# enum4linux
# onesixtyone
# snmp walk

# scanner_nse.sh spawns off a bunch of NSE scanner scripts that may step all over each other, YMMV.
# shell_spawner.sh also uses msfvenom to spit out a number of common shells to your interface's IP.

# This is a quick/dity modification of the original lazymap. 
# Just the original initial nmap scans were kept, I fumbled through making this quickly, so use at your own risk!

# Known bugs:
# -I broke the file input feature and haven't gotten around to fixing it. Currently it only scans a subnet or individual IP addresses. For my use case, I just pop open a bunch of terminator windows and run multiple instances.
# -No error handling, if a scan finds nothing it just keeps going.
# -Sloppy nikto handling, just scans from an nmap output pipe of these ports: 80,8000,8080,8081,8888,443,4443

# Per the limitations and license, be sure to read what this thing does and use at your own risk.

####

######################################################################################
#####################################################################################################################

# User config options

# Turn on/off Nmap scan options

FULLTCP="on" # to disable/enable Full TCP Scan set to "off" / "on"
SCRIPT="on" # to disable/enable safe script Scan set to "off" / "on"
QUICKUDP="on" # to disable/enable quick UDP scan set to "off" / "on" 
COMMONTCP="on" # to disable/enabke commong TCP scan set to "off" / "on"
NIKTO="on"

######################################################################################################################
# Script Starts

echo -e "\e[1;33m----------------------------------------\e[00m"
echo -e "This script is a modification with borrowing from LazyMap nmap scripts, modified under"
echo -e "GNU Affero General Public License v3.0"
echo -e "to work in Kali Linux, for original, see:"
echo -e "https://github.com/nccgroup/port-scan-automation"
echo -e ""
echo -e "This will combine nmap, nmap scripting engine, "
echo -e "nikto, enum4linux, and snmp walk"
echo -e "in one go."
echo -e "\e[1;33m----------------------------------------\e[00m"
echo ""
echo "Starting webserver..."
service apache2 restart
echo ""
echo -e "\e[1;33m----------------------------------------\e[00m"
echo ""
echo "The following Interfaces are available"
echo -e "\e[1;33m----------------------------------------\e[00m"
ifconfig | grep flags | cut -d ":" -f 1

echo -e "\e[1;31m--------------------------------------------------\e[00m"
echo "Enter the interface to scan from as the source"
echo -e "\e[1;31m--------------------------------------------------\e[00m"
read INT

ifconfig | grep -i -w $INT >/dev/null

if [ $? = 1 ]
	then
		echo ""
		echo -e "\e[1;31mSorry the interface you entered does not exist! - check and try again.\e[00m"
		echo ""
		exit 1
else

LOCAL=$(ifconfig $INT | grep inet | grep -v inet6 | cut -d " " -f 10)
MASK=$(ifconfig $INT | grep inet | grep -v inet6 | cut -d " " -f 13)
echo ""
echo -e "Your interface is set to \e[1;33m"$INT"\e[00m with source IP address \e[1;33m"$LOCAL"\e[00m and mask of \e[1;33m"$MASK"\e[00m"
echo -e "Exit now if this is incorrect!"
echo ""
echo -e "\e[1;31m--------------------------------------------------\e[00m"
echo "Enter the reference or client name for the scan"
echo -e "\e[1;31m--------------------------------------------------\e[00m"
read REF

echo ""
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo "Enter the IP address/Range"
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
read RANGE

mkdir "$REF" >/dev/null 2>&1 #Making folder for this scan
cd "$REF"
echo "$REF" > REF
echo "$INT" > INT
echo ""

echo ""
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
echo "Run msfvenom to generate return shells on this adapter?"
echo -e "\e[1;31m-------------------------------------------------------------------\e[00m"
read SHELLCHOICE
if [ $SHELLCHOICE = yes ]
    then
        ../shell_spawner.sh $LOCAL 443 $(pwd) $REF & >shell-spawner-log.txt
    fi


echo -e "\e[1;31m-----------------------------------------------------------------------------------------------------------\e[00m"
echo "Do you want to exclude any IPs from the scan i.e your Windows host? - Enter yes or no and press ENTER"
echo -e "\e[1;31m-----------------------------------------------------------------------------------------------------------\e[00m"
read EXCLUDEANS

if [ $EXCLUDEANS = yes ]
		then
			echo ""
			echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
			echo "Enter the IP addresses to exclude i.e 192.168.1.1, 192.168.1.1-10 - normal nmap format"
			echo -e "\e[1;31m------------------------------------------------------------------------------------------\e[00m"
			read EXCLUDEDIPS
			EXCLUDE="--exclude "$EXCLUDEDIPS""
			echo "$EXCLUDE" > excludetmp
			echo "This following IP addresses were asked to be excluded from the scan = "$EXCLUDEDIPS"" > "$REF"_nmap_hosts_excluded.txt
		else
			EXCLUDE=""
			echo "$EXCLUDE" > excludetmp
		fi

		echo $RANGE |grep "[0-9]" >/dev/null 2>&1
if [ $? = 0 ]
	then
		echo ""
		echo -e "\e[1;33mYou enterted a manual IP or range, scan will now start...\e[00m"
		echo ""
		echo -e "\e[1;33m$REF - Finding Live hosts via $INT, please wait...\e[00m"
		nmap -e $INT -sn $EXCLUDE -PE -PM -PS21,22,23,25,26,53,80,81,110,111,113,135,139,143,179,199,443,445,465,514,548,554,587,993,995,1025,1026,1433,1720,1723,2000,2001,3306,3389,5060,5900,6001,8000,8080,8443,8888,10000,32768,49152 -PA21,80,443,13306 -vvv -oA "$REF"_nmap_PingScan $RANGE >/dev/null
		cat "$REF"_nmap_PingScan.gnmap |grep "Up" |awk '{print $2}' > "$REF"_hosts_Up.txt
		cat "$REF"_nmap_PingScan.gnmap | grep  "Down" |awk '{print $2}' > "$REF"_hosts_Down.txt
	else
		echo ""
		echo -e "\e[1;33mYou entered a file as the input, I will just check I can read it ok...\e[00m"
		cat $RANGE >/dev/null 2>&1
			if [ $? = 1 ]
			then
				echo ""
				echo -e "\e[1;31mSorry I can't read that file, check the path and try again!\e[00m"
				echo ""
			exit 1
		else
			echo ""
			echo -e "\e[1;33mI can read the input file ok, Scan will now start...\e[00m"
			echo ""
			echo -e "\e[1;33m$REF - Finding Live hosts via $INT, please wait...\e[00m"
			nmap -e $INT -sn $EXCLUDE -PE -PM -PS21,22,23,25,26,53,80,81,110,111,113,135,139,143,179,199,443,445,465,514,548,554,587,993,995,1025,1026,1433,1720,1723,2000,2001,3306,3389,5060,5900,6001,8000,8080,8443,8888,10000,32768,49152 -PA21,80,443,13306 -vvv -oA "$REF"_nmap_PingScan -iL $RANGE >/dev/null
			cat "$REF"_nmap_PingScan.gnmap |grep "Up" |awk '{print $2}' > "$REF"_hosts_Up.txt
			cat "$REF"_nmap_PingScan.gnmap | grep  "Down" |awk '{print $2}' > "$REF"_hosts_Down.txt
		fi
        fi
fi

echo ""
echo -e "\e[1;33mHosts found...\e[00m"
cat "$REF"_hosts_Up.txt
echo ""
for IPfolders in $(cat "$REF"_hosts_Up.txt);do mkdir $IPfolders;done #Make host folders

echo -e "\e[1;33mScanning for DNS...\e[00m"
nmap -e $INT -p53 -iL "$REF"_hosts_Up.txt -oG - | grep open | cut -d " " -f 2 | tee "$REF"_dnsservers.txt  >/dev/null

if [ $? = 0 ]
        then
                echo ""
                echo -e "\e[1;33mDNS Possibilities...\e[00m"
                cat "$REF"_dnsservers.txt
                echo ""
                echo -e "\e[1;33mUsing first option...\e[00m"
                LOCALDNS=$(head -n 1 "$REF"_dnsservers.txt)
                for IPS in $(cat "$REF"_hosts_Up.txt); do nslookup $IPS $LOCALDNS | tee $IPS/hostname.txt;done
        else
                echo ""
                echo -e "\e[1;33mNo local DNS found...\e[00m"
        fi

echo -e "\e[1;33mProducing clean nmap -sV scan files and nikto scans of webhosts...\e[00m"
for IPS in $(cat "$REF"_hosts_Up.txt); do 
nmap -e $INT -sV -T5 $IPS -oA $IPS/nmap >/dev/null &
done

#Start Nikto Scans
for IPS in $(cat "$REF"_hosts_Up.txt); do 
nmap -e $INT -p80,8000,8080,8081,8888,443,4443 -T5 $IPS -oG - | nikto -h - >>$IPS/nikto.txt &
done
echo ""

#Wait until nmap scans complete:
sleep 5s
while pgrep nmap > /dev/nul; do sleep 5s; done

echo ""
echo -e "\e[1;33mNmap scans complete.\e[00m" #Nikto likely still going
echo ""

#echo out TCP Ports to each file
for IPS in $(cat "$REF"_hosts_Up.txt); 
do cat $IPS/nmap.nmap | grep open | cut -d "/" -f 1 >>$IPS/tcpports.txt;
done

#categorize by service:


#FTP
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 21 $IPS/tcpports.txt;then echo $IPS >>ip_ftp.txt;fi);
done

#SSH
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 22 $IPS/tcpports.txt;then echo $IPS >>ip_ssh.txt;fi);
done

#telnet
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 23 $IPS/tcpports.txt;then echo $IPS >>ip_telnet.txt;fi);
done

#smtp
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 25 $IPS/tcpports.txt;then echo $IPS >>ip_smtp.txt;fi);
done

#tftp
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 69 $IPS/tcpports.txt;then echo $IPS >>ip_tftp.txt;fi);
done

#web
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if egrep -q '80|8000|8080|8081|8888|443|4443' $IPS/tcpports.txt;then echo $IPS >>ip_web.txt;fi);
done

#smb 
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if egrep -q '13[5-9]|445' $IPS/tcpports.txt;then echo $IPS >>ip_smb.txt;fi);
done

# snmp
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 161 $IPS/tcpports.txt;then echo $IPS >>ip_snmp.txt;fi);
done

#ldap
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 389 $IPS/tcpports.txt;then echo $IPS >>ip_ldap.txt;fi);
done

#https
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 443 $IPS/tcpports.txt;then echo $IPS >>ip_https.txt;fi);
done

#mssql
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if egrep -q '1433|1434' $IPS/tcpports.txt;then echo $IPS >>ip_mssql.txt;fi);
done

#rdp
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if grep -q 3389 $IPS/tcpports.txt;then echo $IPS >>ip_rdp.txt;fi);
done

#vnc
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if egrep -q '5[800-910]' $IPS/tcpports.txt;then echo $IPS >>ip_vnc.txt;fi);
done

#X11
for IPS in $(cat "$REF"_hosts_Up.txt); 
do (if egrep -q '60[00-10]|69[00-10]' $IPS/tcpports.txt;then echo $IPS >>ip_x11.txt;fi);
done

####
# Now tell us what you found
####

for services in $(ls ip_* | cut -d "_" -f 2 | cut -d "." -f 1);
do 
    echo -e "\e[1;33mHosts with $services\e[00m"
    cat ip_$services.txt && echo "";
done

##Nikto probably still running, let us know
if pgrep nikto > /dev/nul; then echo -e "\e[1;33mNote: Nikto still running in background \e[00m" && echo "";fi

#Concurrently start UDP nmap scans:
echo -e "\e[1;33mFiring off quick UDP scans in background.\e[00m"
for IPS in $(cat "$REF"_hosts_Up.txt); do
nmap -e $INT -sU -Pn -T5 -vvv $IPS -oA $IPS/nmap_quickudp -n >/dev/null &
done

echo -e "\e[1;33mSNMP scanning these hosts: \e[00m"
cat ip_snmp.txt

echo -e "\e[1;33mOnesixtyone against SNMP hosts... \e[00m"
echo public > community.txt
echo private >> community.txt
echo manager >> community.txt
echo ACME >> community.txt
echo THINC >> community.txt
onesixtyone -c community.txt -i ip_snmp.txt | tee -a onesixtyone.txt

echo -e "\e[1;33mSNMPWalk against SNMP hosts... \e[00m"
for ips in $(cat ip_snmp.txt); do
    snmpwalk -c public -v1 $ips 1.3.6.1.4.1.77.1.2.25 | cut -d ":" -f 2 | cut -d '"' -f 2 > $ips/snmp_users.txt &&
    snmpwalk -c public -v1 $ips 1.3.6.1.2.1.25.4.2.1.2 | cut -d ":" -f 2 | cut -d '"' -f 2 > $ips/snmp_processes.txt &&
    snmpwalk -c public -v1 $ips 1.3.6.1.2.1.6.13.1.3 | cut -d ":" -f 2 | cut -d '"' -f 2 > $ips/snmp_tcp.txt &&
    snmpwalk -c public -v1 $ips 1.3.6.1.2.1.25.6.3.1.2 | cut -d ":" -f 2 | cut -d '"' -f 2 > $ips/snmp_software.txt &
done

while ps agx | grep snmp | grep walk > /dev/nul; do sleep 5s; done

echo -e "\e[1;33mEnum4linux against all hosts... \e[00m"
for ips in $(cat "$REF"_hosts_Up.txt); do
    enum4linux $ips > $ips/enum4linux.txt &
done

while ps agx | grep enum4 | grep linux > /dev/nul; do sleep 5s; done

echo -e "\e[1;33mHere it comes, nmap NSE scans, prepare yourself. \e[00m"
echo -e "\e[1;33mScript outputs will dump in the host subfolders. \e[00m"
echo -e "\e[1;33mTo see all possible nmap scripts, run: \e[00m"
echo -e "\e[1;33mroot@kali:/# ls /usr/share/nmap/scripts/ \e[00m"

for SERVICES in $(ls ip_* | cut -d "_" -f 2 | cut -d "." -f 1); do #Get services found
    for RHOST in $(cat ip_$SERVICES.txt); do
        ../scanner_nse.sh $INT $(pwd) $SERVICES $RHOST & #spawn these NSEs like crazy
    done; 
done

sleep 5s
while ps agx | grep scanner_ns | grep bash > /dev/nul; do sleep 5s; done
echo -e "\e[1;33mNSE scripts done, script outputs will dump in the host subfolders. \e[00m"

echo -e "\e[1;33mNSE scripts result Vulnerable summary: \e[00m"

for ips in $(cat "$REF"_hosts_Up.txt);do for vals in $(ls $ips/nmap_nse*);do echo $ips && cat $vals| grep -B1 VULN | tee -a $ips/vulns.txt;done;done

exit

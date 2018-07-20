LazyMap - Auto NMAP Scanning Script
============================================

**WARNING**: This fork has significant divergence from the original LazyMap!

**Please** read the lazymap.sh preamble and script very carefully!

This fork is modified for running additional enumeration:
* nmap
* nmap NSEs
* nikto
* enum4linux
* onesixtyone
* snmp walk

It also calls these two scripts:
* **scanner_nse.sh** spawns off a bunch of NSE scanner scripts that may step all over each other, YMMV.
* **shell_spawner.sh** uses msfvenom to spit out a number of reverse shells pointed at your interface's IP.

Just the original initial nmap scans were kept, I fumbled through making this quickly, so use at your own risk!

Known bugs:
* I broke the file input feature and haven't gotten around to fixing it. Currently it only scans a subnet or individual IP addresses. For my use case, I just pop open a bunch of terminator windows and run multiple instances.
* No error handling, if a scan finds nothing it just keeps going.
* Sloppy nikto handling, just scans from an nmap output pipe of these ports: 80,8000,8080,8081,8888,443,4443

Be sure to read what this thing does and use at your own risk!


Original notes:


Automate NMAP scans and custom Nessus polices.

Released as open source by NCC Group Plc - http://www.nccgroup.com/

Developed by Daniel Compton, daniel dot compton at nccgroup dot com

https://github.com/nccgroup/port-scan-automation

Released under AGPL see LICENSE for more information

Installing  
=======================
    git clone https://github.com/BUGLESPIDER/port-scan-automation


How To Use	
=======================
    ./lazymap.sh


Features	
=======================

Runs these scans for enumeration:
* nmap
* some common nmap NSE scripts
* nikto
* enum4linux
* onesixtyone
* snmp walk

Optional shell spawner using msvenom.

Requirements   
=======================
Tested on Kali, so needs:
* nmap
* nmap NSEs
* nikto
* enum4linux
* onesixtyone
* snmp walk
* msfvenom


Screen Shot    
=======================
<img src="http://www.commonexploits.com/wp-content/uploads/2012/12/ping.png" alt="Screenshot" style="max-width:100%;">

<img src="http://www.commonexploits.com/wp-content/uploads/2012/12/scans.png" alt="Screenshot" style="max-width:100%;">

<img src="http://www.commonexploits.com/wp-content/uploads/2012/12/unique.png" alt="Screenshot" style="max-width:100%;">

Change Log
=======================

* Version 2 - Additional enumeration scripts for Kali Linux, added shell spawner for msfvenom-created shells
* Version 1.8 - Official release.



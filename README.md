LazyMap - Auto NMAP Scanning Script
============================================

**WARNING**: This fork has significant divergence from the original LazyMap!

**Please** read the lazymap.sh preamble and script very carefully!

This fork is modified for running additional enumeration:
nmap
nmap NSEs
nikto
enum4linux
onesixtyone
snmp walk

It also calls these two scripts:
**scanner_nse.sh** spawns off a bunch of NSE scanner scripts that may step all over each other, YMMV.
**shell_spawner.sh** uses msfvenom to spit out a number of common shells to your interface's IP.

Just the original initial nmap scans were kept, I fumbled through making this quickly, so use at your own risk!

Known bugs:
I broke the file input feature and haven't gotten around to fixing it. Currently it only scans a subnet or individual IP addresses. For my use case, I just pop open a bunch of terminator windows and run multiple instances.
No error handling, if a scan finds nothing it just keeps going.
Sloppy nikto handling, just scans from an nmap output pipe of these ports: 80,8000,8080,8081,8888,443,4443

Per the limitations and license, be sure to read what this thing does and use at your own risk!


Original notes:


Automate NMAP scans and custom Nessus polices.

Released as open source by NCC Group Plc - http://www.nccgroup.com/

Developed by Daniel Compton, daniel dot compton at nccgroup dot com

https://github.com/nccgroup/port-scan-automation

Released under AGPL see LICENSE for more information

Installing  
=======================
    git clone https://github.com/nccgroup/port-scan-automation.git


How To Use	
=======================
    ./lazymap.sh


Features	
=======================

* Discovers live devices
* Auto launches port scans on only the discoverd live devices
* Can run mulitple instances on multiple adaptors at once
* Creates client Ref directory for each scan
* Outputs all unique open ports in a Nessus ready format. Much faster to scan in Nessus.
* Runs as default a T4 speed scan. If you find this too slow, you can press CTRL C in the scan window and it will cleanup and relaunch that one scan with T5 speed option.
* Logs all start/stop times, live hosts, hosts down, unique ports.
* Auto creates a custom Nessus policy with only the discovered ports, must faster to scan. *

* * Read the script header carefully, in order for the auto Nessus policy creater you must first save a default template to the same directory as the script. The script will detect the default template and create you a unique Nessus policy after each scan for just the unique ports. Then simply import the policy into Nessus and scan just the live devices that the  script found. This will save a massive amount of time scanning, plus will give you more accurate findings.

* * By Default it will scan a full TCP, Quick UDP, Common ports and a Safe Script scan. You can turn these on and off in the header. 

Requirements   
=======================
* NMAP http://www.nmap.org

Tested on Backtrack 5 and Kali.


Screen Shot    
=======================
<img src="http://www.commonexploits.com/wp-content/uploads/2012/12/ping.png" alt="Screenshot" style="max-width:100%;">

<img src="http://www.commonexploits.com/wp-content/uploads/2012/12/scans.png" alt="Screenshot" style="max-width:100%;">

<img src="http://www.commonexploits.com/wp-content/uploads/2012/12/unique.png" alt="Screenshot" style="max-width:100%;">

Change Log
=======================

Version 2 - Additional enumeration scripts for Kali Linux, added shell spawner for msfvenom-created shells
Version 1.8 - Official release.



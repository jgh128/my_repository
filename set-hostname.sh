#!/bin/bash
###########################################################
###          Hostname Configurator version 0.4          ###
###   For Plesk, Plesk6, Ensim, Cpanel, and Plain RH    ###
###########################################################

###########################################################
###                      Functions                      ###
###########################################################
###query for cptype
function cptype {
        echo "What type of CP is this?"
        echo "Type P for Plesk Standard (psa5.0.* or below)"
  echo "Type PR for Plesk RPM (psa5.0.* or below)"
	echo "Type PSA for Plesk (plesk6.0.* or higher)"
        echo "Type E for Ensim"
        echo "Type C for Cpanel"
        echo "Type PLAIN for Plain Redhat"
        echo -n "[P,PR,PSA,E,C,PLAIN]: " 
        read CP
                if [ "$CP" == "P" ]; then
                        CP2="Plesk Standard"
                elif [ "$CP" == "p" ]; then
                        CP2="Plesk Standard"
                elif [ "$CP" == "PR" ]; then
                        CP2="Plesk rpm"
                elif [ "$CP" == "pr" ]; then
                        CP2="Plesk rpm"
		elif [ "$CP" == "PSA" ]; then
			CP2="PLESK6"
		elif [ "$CP" == "psa" ]; then
			CP2="PLESK6"
                elif [ "$CP" == "E" ]; then
                        CP2="Ensim"
                elif [ "$CP" == "e" ]; then
                        CP2="Ensim"
                elif [ "$CP" == "C" ]; then
                        CP2="Cpanel"
                elif [ "$CP" == "c" ]; then
                        CP2="Cpanel"
                elif [ "$CP" == "PLAIN" ]; then
                        CP2="Plain RedHat"
                elif [ "$CP" == "plain" ]; then
                        CP2="Plain RedHat"
                elif [ "$CP" == "Plain" ]; then
                        CP2="Plain RedHat"
                elif [ "$CP" == "PL" ]; then
                        CP2="Plain RedHat"
                else
                        echo "Answer not read, Aborting, Please Try Again."
			footer
                        exit 1
                        fi
}
function getinfo {
        echo "Please enter hostname"
        echo -n "(sub.domain.com): "
        read H1
        HOST=$H1
        echo $HOST > host.txt
        H2=`cut -f 1 -d . host.txt`
        rm -f host.txt
        HOSTSHORT=$H2
        echo "Please enter server ip#"
        echo -n "(123.123.123.123): "
        read H3
        IP=$H3
        echo $IP > temp.txt
        H4=`cut -f 1,2,3 -d . temp.txt`
        rm -f temp.txt
        IP2=$H4.1
}
function verify {
        echo "You have selected hostname: $HOST at $IP on a $CP2 box with a gateway ip of $IP2"
        echo "This is your last chance to change your mind."
        echo "Is this correct?"
        echo -n "[y/n]: "
        read val
        if [ "$val" == "y" ]; then
        echo "setting hostname"
        elif [ "$val" == "Y" ]; then
        echo "setting hostname"
        elif [ "$val" == "n" ]; then
                echo "Aborting, Please Try Again."
                footer
                exit 1
        elif [ "$val" == "N" ]; then
                echo "Aborting, Please Try Again."
                footer
                exit 1
        else 
                echo "Answer not read, Aborting, Please Try Again."
                footer
                exit 1
         fi
}
function start {
                if [ "$CP" == "P" ]; then
                        sethostname
                        hostnameplesk
                elif [ "$CP" == "p" ]; then
                        sethostname
                        hostnameplesk
                elif [ "$CP" == "PSA" ]; then
                        sethostname
			hostnamepsa
                elif [ "$CP" == "psa" ]; then
                        sethostname
			hostnamepsa			
                elif [ "$CP" == "PR" ]; then
                        sethostname
                        hostnameplesk
                elif [ "$CP" == "pr" ]; then
                        sethostname
                        hostnameplesk
                elif [ "$CP" == "E" ]; then
                        sethostname
                elif [ "$CP" == "e" ]; then
                        sethostname
                elif [ "$CP" == "C" ]; then
                        sethostname
                elif [ "$CP" == "c" ]; then
                        sethostname
                elif [ "$CP" == "PLAIN" ]; then
                        sethostname
                elif [ "$CP" == "plain" ]; then
                        sethostname
                else
                        echo echo "Answer not read, Aborting, Please Try Again."
                        exit 1
                        fi
}
function hostnameplesk {
        /usr/local/psa/bin/reconfigurator.sh 
}
function hostnamepsa {
        mysql -uadmin -p`cat /etc/psa/.psa.shadow` psa -e "update misc set val='$HOST' where param='FullHostName'"
	echo "$HOST" > /var/qmail/control/me
	echo "$HOST" >>/var/qmail/control/locals
}
function sethostname {
        hostname $HOST
        cp /etc/sysconfig/network /etc/sysconfig/network.backup
        rm -f /etc/sysconfig/network
        echo NETWORKING=yes >>            /etc/sysconfig/network
        echo HOSTNAME=\""$HOST"\" >>      /etc/sysconfig/network
        echo GATEWAY=\""$IP2"\" >>         /etc/sysconfig/network
        echo GATEWAYDEV=\"eth0\" >>       /etc/sysconfig/network
        echo FORWARD_IPV4=\"yes\" >>      /etc/sysconfig/network
        cp /etc/hosts /etc/hosts.backup
        rm -rf /etc/hosts
        echo # Do not remove the following line, or various programs >> /etc/hosts
        echo # that require network functionality will fail. >>         /etc/hosts
        echo 127.0.0.1       localhost.localdomain   localhost >>       /etc/hosts
        echo "$IP"    $HOST     $HOSTSHORT >>  /etc/hosts
	/etc/rc.d/init.d/syslog restart
}
###clean up
function finish {
        echo "removing myself...have a nice day"
        echo "type \"hostname\" to verify the hostname change"
        cd /
        rm -Rf /nh
        rm -f /root/hostname.sh
}

###Informative Header
function header {
clear
echo "##########################################################"
echo "###            Initial Hostname Setup Script           ###"
echo "##########################################################"
}
###########################################################
###                    End Functions                    ###
###########################################################

###########################################################
###                    start script                     ###
###########################################################
header
cptype
getinfo
verify
start
finish
exit 0

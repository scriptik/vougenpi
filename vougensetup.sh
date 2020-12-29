#!/bin/bash
###################################################################
#Script Name	: vougensetup.sh
#Description	: Installation script for vougenpi package
#Author       	: Pezhman Shafigh
#Email         	: pezhmanshafigh@gmail.com
#date           : December 2020
#license        : MIT

DBSERVER=localhost
DATABASE=vougen
USER=root

clear
if [ "$(id -u)" != "0" ]
then
	echo "You are not root"
	echo "Please run again with sudo"
	exit 1
fi
cat < license.txt
sleep .5
echo "This script will install vougen package to your Raspberry Pi"
sleep .5
read -p "Do you want install this software ?(y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    echo "The installation was aborted by the user"
    exit 1
fi

echo "Check requirements ..."
sleep .5

#if ! qrencode -V &> /dev/null
#then
#    echo "qrencode could not be found"
#    exit
#fi
#echo "qrencode .......... Ok"
#sleep .25

#Applist="mysql ncat php qrencode"
Applist="mysql qrencode"
for App in $Applist; do
    if ! which $App &> /dev/null
    then
        #echo "$App     could not be found"
        printf "%-9s ......... NA\n" "$App"
        exit
    fi
    printf "%-9s ......... Ok\n" "$App"
    sleep .25
done

#Pythonlist="gpiozero escpos pygame"
Pythonlist="gpiozero escpos"
for Package in $Pythonlist; do
    if  python3 -c "import sys, pkgutil; sys.exit(1 if pkgutil.find_loader('$Package') else 0)"
    then
        #echo "$Package could not be found"
        printf "%-9s ......... NA\n" "$Package"
        exit
    fi
    printf "%-9s ......... Ok\n" "$Package"
    sleep .25
done

#SSH_KEY=/home/pi/.ssh/id_rsa
#ssh -i $SSH_KEY -o StrictHostKeyChecking=no pi@192.168.100.254 -p 1600 "/system resource print"

read -sp 'Enter mariaDB root password:' PASS
echo -e "\nconnection check ....."
sleep .5
if ! mysql -u root -p$PASS  -e "SELECT VERSION();" 2> /dev/null 
then
    echo "connection .... failed"
    exit
fi
echo "connection ....... Ok"
sleep .5
printf "Creating vougen database... This may take a while\n"
mysql -u root -p$PASS < ./vougen.sql
printf "Creating USER 'vouser'@'localhost' IDENTIFIED BY 'voupass'\n"
sleep .25
mysql -u root -p$PASS <<EOF
CREATE USER 'vouser'@'localhost' IDENTIFIED BY 'voupass';
GRANT SELECT,INSERT,UPDATE ON vougen.* TO 'vouser'@'localhost';
EOF


echo "Creating directory ..."
mkdir -p /opt/vougen/inbox
mkdir -p /home/pi/vougen/{qrcodes,template,vouchers}
sleep .25
echo "Copy files ..."
cp ./template_0.jpg /home/pi/vougen/template/
cp ./src/* /opt/vougen/
touch /opt/vougen/inbox/new.txt
chmod 666 /opt/vougen/inbox/new.txt
chmod 666 /opt/vougen/vougen.conf
chmod 666 /opt/vougen/gpiorder.conf
chmod 666 /opt/vougen/config.yaml
sleep .25
#cp ./ser/vougen.service /lib/systemd/system/
#cp ./ser/vougen.path /lib/systemd/system/
#cp ./ser/gpiobutton.service /lib/systemd/system/
cp ./ser/* /lib/systemd/system/
sleep .25
cat /opt/vougen/gpiorder.conf > /opt/vougen/inbox/new.txt
echo "Creating soft links ..."
ln -s /lib/systemd/system/vougen.service /etc/systemd/system/vougen.service
ln -s /lib/systemd/system/vougen.path /etc/systemd/system/vougen.path
ln -s /lib/systemd/system/gpiobutton.service /etc/systemd/system/gpiobutton.service
ln -s /opt/vougen/vougen.conf /home/pi/vougen/vougen.conf 
ln -s /opt/vougen/gpiorder.conf /home/pi/vougen/gpiorder.conf 
ln -s /opt/vougen/config.yaml /home/pi/vougen/config.yaml 

systemctl enable vougen.path
systemctl start vougen.path
echo "vougen enabled, Checking status ..."
sleep .25
systemctl status vougen.path
read -p "Do you want enable gpio key service ?(y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "gpio key enabled, Checking status ..."
    sleep .25
    systemctl enable gpiobutton.service
    systemctl start gpiobutton.service
    echo "gpiobutton enabled, Checking status ..."
    sleep .25
    systemctl status gpiobutton.service
else
    echo "You can enable it later by << sudo systemctl enable gpiobutton.service >>"
fi
sleep .25
echo "Installation completed , read more info on www.github.com/scriptik/vougenpi/"

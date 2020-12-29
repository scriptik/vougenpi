# vougenpi
The Raspberry Pi script to generate and print vouchers for hotspot access using Mikrotik routers 

Vougenpi can be used in two different operations : directly key mode , file mode

THIS GUIDE WILL BE UPDATED AS SOON AS POSSIBLE

## System requirements
##### Hardware
Vougenpi requires

Raspberry Pi card

Mikrotik router

ESC/POS Printer

##### Software

last Raspberry Pi OS (Lite version is recommended)

Mariadb

![qrencode](https://fukuchi.org/works/qrencode/) The command-line utility to create a QR code

![escpos](https://github.com/python-escpos/python-escpos) Python library to manipulate ESC/POS Printers

## Configuration RouterOS SSH
Vougenpi requires RouterOS SSH public/private key login 

![RouterOS SSH public/private key login](https://wiki.mikrotik.com/wiki/Use_SSH_to_execute_commands_(public/private_key_login))

## Installation 
Get the latest.tar.gz release and extract it. Then run:

tar -xzvf latest.tar.gz

cd latest

sudo ./vougensetup.sh


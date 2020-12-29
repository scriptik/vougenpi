# vougenpi
The Raspberry Pi script to generate and print vouchers for hotspot access using Mikrotik routers 

## System requirements
Raspberry Pi card

Mikrotik router

Vougenpi requires last Raspberry Pi OS (Lite version is recommended)

Mariadb

## Installation 
Get the latest.tar.gz release and extract it. Then run:

tar -xzvf latest.tar.gz

cd latest

sudo ./vougensetup.sh

## Built with
![qrencode](https://fukuchi.org/works/qrencode/) The command-line utility to create a QR code

![escpos](https://github.com/python-escpos/python-escpos) Python library to manipulate ESC/POS Printers

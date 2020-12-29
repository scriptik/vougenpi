#!/usr/bin/python3
import os
#import time
import configparser
from gpiozero import Button
#from gpiozero import LED
from signal import pause

config = configparser.ConfigParser()
config.read('/opt/vougen/vougen.conf')
gpio = config['gpio']
#led_number = gpio['led']
key_number = int(gpio['key'])

def send_request():
    #os.system('echo 1,1,1d,1 > /opt/vougen/inbox/new.txt')
    os.system('cat /opt/vougen/gpiorder.conf > /opt/vougen/inbox/new.txt')
    #led = LED(16)
    #led.on()
    #time.sleep(3) # Sleep for 3 seconds
    #led.off()
#button = Button(21)
button = Button(key_number)

button.when_pressed = send_request

pause()

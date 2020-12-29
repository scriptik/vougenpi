#!/usr/bin/python3
import time
import configparser
from gpiozero import LED

config = configparser.ConfigParser()
config.read('./vougen.conf')
gpio = config['gpio']
led_number = gpio['led']
led = LED(led_number)
led.on()
time.sleep(3) # Sleep for 3 seconds
led.off()

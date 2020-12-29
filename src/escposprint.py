import sys
import time
from escpos import config

def printvoucher(img):
    img = img
    c = config.Config()
    c.load("/opt/vougen/config.yaml")
    p = c.printer()

    p.set(font='a', height=1, align='center')
    #p.image("final.jpg")
    p.image(img)
    issuetime = time.strftime('%X %x')
    p.text("\n")
    p.text(issuetime+"\n")
    ##time.sleep(1)
    ## Cut paper
    p.cut()

printvoucher(sys.argv[1])

import sys
from PIL import Image, ImageDraw, ImageFont

# add qrcode
def addqrcode(input_image_path,
                    output_image_path,
                    qrcode_path,
                    position):
    base_image = Image.open(input_image_path)
    qrcode = Image.open(qrcode_path)

    # add qrcode to your image
    base_image.paste(qrcode, position)
    #output_image.save()
    base_image.save(output_image_path)

# add profile, username , password
def addupu(un, pw, pr, temp):
    username = un
    password = pw
    profile = pr
    temp = temp
    #template = Image.open('./template_0.jpg')
    template = Image.open(temp)
    d1 = ImageDraw.Draw(template)
    myFont = ImageFont.truetype('/usr/share/fonts/truetype/freefont/FreeMono.ttf', 35)
    d1.text((220, 130), profile, font=myFont, fill =(0, 0, 0))
    d1.text((270, 245), username, font=myFont, fill =(0, 0, 0))
    d1.text((270, 325), password, font=myFont, fill =(0, 0, 0))
    template.save("/tmp/last_urpr.jpg")

#addupu("1 DAY Access", "Hotel987321", "PS#986tr$q")
addupu(sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4])
img = '/tmp/last_urpr.jpg'
#addqrcode(img, 'last_voucher.jpg', 'last_qr.png', position=(10,190))
print(img, sys.argv[5], sys.argv[6])
addqrcode(img, sys.argv[5], sys.argv[6], position=(10,190))
#img.show()

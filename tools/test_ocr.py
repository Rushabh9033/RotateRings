import easyocr
import glob

images = glob.glob(r"D:\AI secound Brain\RotateRings\ALL 2to100 levels\*.jpeg")
reader = easyocr.Reader(['en'], gpu=False)

for img_path in images[:2]:
    print("Reading", img_path)
    result = reader.readtext(img_path)
    for res in result:
        print(res[1])

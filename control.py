import serial, json, urllib
from time import sleep

port = '/dev/tty.usbserial-A4008gh1'
url = 'https://semaphoreapp.com/api/v1/projects/277b0da27f3ec94a651ca295139a18cac9d677c0/8810/status?auth_token=VWBMyfWsdPeKL87ZBpgC'

while True:
  ser = serial.Serial(port, 9600, timeout=0)

  resp = urllib.urlopen(url)
  data = json.load(resp)

  result = data["result"]

  ser.write('0')

  if result == "pending":
    ser.write('1')
  elif result == "passed":
    ser.write('4')
  elif result == "failed":
    ser.write('3')
  else:
    print result
    ser.write('5')

  ser.close()

  sleep(10)

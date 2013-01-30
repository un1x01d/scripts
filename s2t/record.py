#!/usr/bin/python2.7
import alsaaudio, wave, numpy
from time import sleep

card = 'sysdefault:CARD=1'

inp = alsaaudio.PCM(alsaaudio.PCM_CAPTURE, alsaaudio.PCM_NONBLOCK, card)
inp.setchannels(1)
inp.setrate(44100)
inp.setformat(alsaaudio.PCM_FORMAT_S16_LE)
inp.setperiodsize(1024)

w = wave.open('test.wav', 'w')
w.setnchannels(1)
w.setsampwidth(2)
w.setframerate(44100)

x = 0
while x != 5:
    l, data = inp.read()
#    a = numpy.fromstring(data, dtype='int16')
#    print numpy.abs(a).mean()
    w.writeframes(data)
    sleep(1)
    x = x+1
    
w.close()

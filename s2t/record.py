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

while True:	
    l, data = inp.read()
    w.writeframes(data)

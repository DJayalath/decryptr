from math import log10
from flask import url_for
from quadgrams_optimized import *

def chisqr(str text):
    
    text = text.upper()
    
    cdef double[26] expected
    expected = [
        0.08167,
        0.01492,
        0.02782,
        0.04253,
        0.12702,
        0.02228,
        0.02015,
        0.06094,
        0.06966,
        0.00153,
        0.00772,
        0.04025,
        0.02406,
        0.06749,
        0.07507,
        0.01929,
        0.00095,
        0.05987,
        0.06327,
        0.09056,
        0.02758,
        0.00978,
        0.02360,
        0.00150,
        0.01974,
        0.00074
        ]
    
    cdef double chi
    chi = 0
    cdef int i
    for i in range(26):
        chi += (((text.count(chr(i+65)))-(expected[i]*len(text)))**2/(expected[i]*len(text)))
    return chi

def indice_coincidence(text):
    
    text = text.upper()
    
    coincidence = 0
    for i in range(26):
        coincidence = coincidence + text.count(chr(i+65))*(text.count(chr(i+65)) - 1)
    
    indexofcoincidence = coincidence/(len(text)*(len(text) - 1))
    
    return indexofcoincidence

class quadgram_score:
    def score(self,str ctext):
        cdef int temp_1
        cdef int temp_2
        cdef int temp_3
        cdef int temp_4
        cdef double score
        cdef int i
        for i in range(len(ctext)-3):
            temp_1 = ord(ctext[i]) - 65
            temp_2 = ord(ctext[i+1]) - 65
            temp_3 = ord(ctext[i+2]) - 65
            temp_4 = ord(ctext[i+3]) - 65
            score += quadgrams[17576*temp_1 + 676*temp_2 + 26*temp_3 + temp_4]
        return score
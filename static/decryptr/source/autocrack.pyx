import random
import numpy as np
from datetime import datetime, timedelta
from analyse import quadgram_score, chisqr, indice_coincidence
import decrypt
fitness = quadgram_score()

def crack_caesar(ctext):

  shifted = []
  stringsqr = []
  for i in range(26):
    shifted.append(decrypt.caesar(ctext,26-i))
    stringsqr.append(chisqr(shifted[i])) # Calculate Chi^2 Statistics
  
  cdef int key
  key = stringsqr.index(min(stringsqr)) # Key will be shift with lowest Chi^2 Statistic
  
  decrypted = decrypt.caesar(ctext,26-key)
  return decrypted

def crack_beaufort(ctext):
  
  ctext = decrypt.atbash(ctext)
  alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  cdef double best_overall
  best_overall = -99e9

  cdef int keylength
  cdef double parentscore
  cdef double best_starter_score
  cdef int i
  cdef double childscore
  
  for keylength in range(1,21):
      parentkey = "A"*keylength
      parentscore = fitness.score(decrypt.vigenere(ctext,parentkey))
      parentkey = list(parentkey)
      best_starter_score = parentscore
      best_starter = "".join(parentkey)
      for i in range(keylength):
          for letter in alphabet:
              parentkey = list(parentkey)
              child = parentkey
              child[i] = letter
              child = "".join(child)
              childscore = fitness.score(decrypt.vigenere(ctext,child))
              if childscore > best_starter_score:
                  best_starter_score = childscore
                  best_starter = child
              if childscore > best_overall:
                  best_overall = childscore
                  best_key = child
          parentkey = best_starter
  return decrypt.vigenere(ctext,best_key)

def crack_vigenere(ctext):
    
  alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  cdef double best_overall
  best_overall = -99e9
  
  cdef int keylength
  cdef double parentscore
  cdef double best_starter_score
  cdef int i
  cdef double childscore

  for keylength in range(1,21):
      parentkey = "A"*keylength
      parentscore = fitness.score(decrypt.vigenere(ctext,parentkey))
      parentkey = list(parentkey)
      best_starter_score = parentscore
      best_starter = "".join(parentkey)
      for i in range(keylength):
          for letter in alphabet:
              parentkey = list(parentkey)
              child = parentkey
              child[i] = letter
              child = "".join(child)
              childscore = fitness.score(decrypt.vigenere(ctext,child))
              if childscore > best_starter_score:
                  best_starter_score = childscore
                  best_starter = child
              if childscore > best_overall:
                  best_overall = childscore
                  best_key = child
          parentkey = best_starter
  return decrypt.vigenere(ctext,best_key)

def crack_substitution(ctext,timeout):
    end_time = datetime.now() + timedelta(seconds=int(timeout))
    maxkey = list('ABCDEFGHIJKLMNOPQRSTUVWXYZ')
    maxscore = -999999999
    cdef double parentscore
    cdef int a
    cdef int b
    cdef double score
    parentscore,parentkey = maxscore,maxkey[:]
    # keep going until we are killed by the user
    i = 0
    while datetime.now() < end_time:
        i = i+1
        random.shuffle(parentkey)
        deciphered = decrypt.substitution(ctext,parentkey)
        parentscore = fitness.score(deciphered)
        count = 0
        while count < 1000 and datetime.now() < end_time:
            a = random.randint(0,25)
            b = random.randint(0,25)
            child = parentkey[:]
            # swap two characters in the child
            child[a],child[b] = child[b],child[a]
            deciphered = decrypt.substitution(ctext,child)
            score = fitness.score(deciphered)
            # if the child was better, replace the parent with it
            if score > parentscore:
                parentscore = score
                parentkey = child[:]
                count = 0
            count = count+1
        # keep track of best score seen so far
        if parentscore>maxscore:
            maxscore,maxkey = parentscore,parentkey[:]
            ss = decrypt.substitution(ctext,maxkey)
    return ss

def crack_2x2hill(ctext):
    alphabet = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    combinations = []
    cdef int i
    cdef int j
    cdef int count
    cdef double s1
    cdef double s2
    for i in range(26):
        for j in range(26):
            combinations.append([i, j])
    cvectors = []
    for i in range(0, len(ctext), 2):
        try:
            cvectors.append([alphabet.index(ctext[i+j]) for j in range(2)])
        except IndexError:
            return "ERROR: Text length must be a multiple of 2"
    decryption_score = []
    count = 0
    for combo in combinations:
        current_decryption = []
        for block in cvectors:
            current_decryption.append(chr(((block[0] * combo[0] + block[1] * combo[1]) % 26) + 65))
        count += 1
        decryption_score.append(chisqr("".join(current_decryption)))
    decryption_score_copy = decryption_score[:]
    best_1 = combinations[decryption_score_copy.index(min(decryption_score))]
    decryption_score.remove(min(decryption_score))
    best_2 = combinations[decryption_score_copy.index(min(decryption_score))]
    for i in range(2):
        best_1[i] = str(best_1[i])
        best_2[i] = str(best_2[i])
    key1 = " ".join(best_1) + " " + " ".join(best_2)
    key2 = " ".join(best_2) + " " + " ".join(best_1)
    decry1 = decrypt.hill2x2(ctext, key1)
    decry2 = decrypt.hill2x2(ctext, key2)
    s1 = fitness.score(decry1)
    s2 = fitness.score(decry2)
    if s1 > s2:
        return decry1
    else:
        return decry2

def crack_3x3hill(ctext):
    alphabet = list("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    combinations = []
    cdef int i
    cdef int j
    cdef int k
    cdef int count
    for i in range(26):
        for j in range(26):
            for k in range(26):
                combinations.append([i, j, k])
    cvectors = []
    for i in range(0, len(ctext), 3):
        try:
            cvectors.append([alphabet.index(ctext[i]), alphabet.index(ctext[i + 1]), alphabet.index(ctext[i+2])])
        except IndexError:
            return "ERROR: Text length must be a multiple of 3"
    decryption_score = []
    count = 0
    for combo in combinations:
        current_decryption = []
        for block in cvectors:
            current_decryption.append(chr(((block[0] * combo[0] + block[1] * combo[1] + block[2] * combo[2]) % 26) + 65))
        count += 1
        decryption_score.append(chisqr("".join(current_decryption)))
    decryption_score_copy = decryption_score[:]
    best_1 = combinations[decryption_score_copy.index(min(decryption_score))]
    decryption_score.remove(min(decryption_score))
    best_2 = combinations[decryption_score_copy.index(min(decryption_score))]
    decryption_score.remove(min(decryption_score))
    best_3 = combinations[decryption_score_copy.index(min(decryption_score))]
    for i in range(3):
        best_1[i] = str(best_1[i])
        best_2[i] = str(best_2[i])
        best_3[i] = str(best_3[i])
    key1 = " ".join(best_1) + " " + " ".join(best_2) + " " + " ".join(best_3)
    key2 = " ".join(best_1) + " " + " ".join(best_3) + " " + " ".join(best_2)
    key3 = " ".join(best_2) + " " + " ".join(best_1) + " " + " ".join(best_3)
    key4 = " ".join(best_2) + " " + " ".join(best_3) + " " + " ".join(best_1)
    key5 = " ".join(best_3) + " " + " ".join(best_1) + " " + " ".join(best_2)
    key6 = " ".join(best_3) + " " + " ".join(best_2) + " " + " ".join(best_1)

    decry = []
    keylist = []
    for key in (key1,key2,key3,key4,key5,key6):
        keylist.append(key)
        decry.append(decrypt.hill3x3(ctext,key))
    s = []
    for decryption in decry:
        s.append(fitness.score(decryption))
    s2 = s[:]
    for i in range(6):
        x = s2.index(max(s))
        if i == 0:
            complete = decry[x]
            return complete
        if i != 5:
            s.remove(max(s))

def crack_bifid(ctext,period,timeout):
  end_time = datetime.now() + timedelta(seconds=int(timeout))
  key = 'ABCDEFGHIKLMNOPQRSTUVWXYZ' # J removed!
  
  def shuffle(key):
      a = random.randint(0, len(key)-1)
      b = random.randint(0, len(key)-1)
      rand_1 = key[a]
      rand_2 = key[b]
      shuffled_key = list(key)
      shuffled_key[b] = rand_1
      shuffled_key[a] = rand_2
      return "".join(shuffled_key)
  
  points = -1000000
  
  max_points = points
  
  t = 1.0
  
  freezing = 0.9997
  
  while t > 0.0001 and datetime.now() < end_time:
      new_key = shuffle(key)
      deciphered = decrypt.bifid(ctext,new_key,period)
      p = fitness.score(deciphered)
      if p > points:
          if p > max_points:
              max_points = p
              print("\nTEMPERATURE", t)
              print("POINTS", p)
              print("KEY", new_key)
              print(deciphered)
          key = new_key
          points = p
  
      else:
          if random.random() < t:
              points = p
              key = new_key
      t *= freezing
      
  return decrypt.bifid(ctext,key,period)

# def crack_vigenere_affine(ctext):
  # alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  # best_overall = -99e9
  # coprime_26 = [3, 5, 7, 9, 11, 15, 17, 19, 21, 23] # Removed 1 and 25 to save time
  
  # average = []
  # for j in range(2,16):
    # sequence = []
    # for k in range(j):
      # text = list(ctext[k:])
      # n = j
      # period = int(int(len(text))//int(n))
      # output = []
      # i=0
      # while i < len(text):
        # output.append(text[i])
        # i = i + int(n)
      # phrase = "".join(output)
      # sequence.append(indice_coincidence(phrase)) # Calculate each index of coincidence
    # average.append(sum(sequence)/len(sequence)) # Calculate average IC for each period
  
  # keylength = average.index(max(average)) + 2

  # for a in coprime_26:
      # parentkey = "A"*keylength
      # parentscore = fitness.score(decrypt.vigenereaffine(ctext,parentkey,a))
      # parentkey = list(parentkey)
      # best_starter_score = parentscore
      # best_starter = "".join(parentkey)
      # for i in range(keylength):
          # for letter in alphabet:
              # parentkey = list(parentkey)
              # child = parentkey
              # child[i] = letter
              # child = "".join(child)
              # childscore = fitness.score(decrypt.vigenereaffine(ctext,child,a))
              # if childscore > best_starter_score:
                  # best_starter_score = childscore
                  # best_starter = child
              # if childscore > best_overall:
                  # best_overall = childscore
                  # best_key = child
                  # best_a = a
                  # print("\nTYPE: VIGENERE (AFFINE)")
                  # print("KEY: %s" %(best_key))
                  # print(decrypt.vigenereaffine(ctext,best_key,a))
          # parentkey = best_starter
          
  # return process_encryption.restore_punctuation(decrypt.vigenereaffine(ctext,best_key,best_a))

# def crack_vigenere_scytale(ctext):
  
  # alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  # best_overall = -99e9
  # best_scytale = -99e9
  
  # for scytale in range(1,11):
      # cipher = pycipher.ColTrans(alphabet[0:scytale+1]).decipher(ctext)
      # for keylength in range(1,21):
          # parentkey = "A"*keylength
          # parentscore = fitness.score(decrypt.vigenere(cipher,parentkey))
          # parentkey = list(parentkey)
          # best_starter_score = parentscore
          # best_starter = "".join(parentkey)
          # for i in range(keylength):
              # for letter in alphabet:
                  # parentkey = list(parentkey)
                  # child = parentkey
                  # child[i] = letter
                  # child = "".join(child)
                  # childscore = fitness.score(decrypt.vigenere(cipher,child))
                  # if childscore > best_starter_score:
                      # best_starter_score = childscore
                      # best_starter = child
                  # if childscore > best_overall:
                      # best_overall = childscore
                      # best_key = child
              # parentkey = best_starter
              
      # current_scytale = fitness.score(decrypt.vigenere(cipher,best_key))
      # if current_scytale > best_scytale:
          # best_scytale = current_scytale
          # scytalenum = scytale
          # print("\nTYPE: VIGENERE + SCYTALE")
          # print("SCYTALE WIDTH: ",str(scytale + 1))
          # print("KEY:",str(best_key))
          # print(decrypt.vigenere(cipher,best_key))
  # return decrypt.vigenere(pycipher.ColTrans(alphabet[0:scytalenum+1]).decipher(ctext),best_key)
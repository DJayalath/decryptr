import string as stringRef
import re
from autocrack import crack_vigenere, crack_caesar, crack_substitution, crack_beaufort, crack_2x2hill, crack_3x3hill, crack_bifid

def removeFormatting(stringf):
    return re.sub("[^a-zA-Z]+", "", stringf)

def saveFormatting(string):

    symbolIndex = []

    for i in range(len(string)):

        if string[i].islower():
            symbolIndex.append([i,"$"])
        elif string[i] not in list(stringRef.ascii_uppercase):
            symbolIndex.append([i,string[i]])

    return symbolIndex

def restoreFormatting(string, symbolIndex):

    for index in symbolIndex:

        if index[1] == "$":
            string = string[:index[0]] + string[index[0]].lower() + string[index[0] + 1:]
        else:
            string = string[:index[0]] + index[1] + string[index[0]:]

    return string

def decrypt_this(text_orig,cipher,type,timeout):
    formatIndex = saveFormatting(text_orig)
    text = removeFormatting(text_orig)
    if text != "":
        processed_text = text.upper()
        if cipher == "1":
            deciphered_text = crack_caesar(processed_text)
        elif cipher == "2":
            deciphered_text = crack_vigenere(processed_text)
        elif cipher == "3":
            deciphered_text = crack_substitution(processed_text,timeout)
        elif cipher == "4":
            deciphered_text = crack_beaufort(processed_text)
        elif cipher == "5":
            if type == "2":
                deciphered_text = crack_2x2hill(processed_text)
            elif type == "3":
                deciphered_text = crack_3x3hill(processed_text)
        elif cipher == "6":
            deciphered_text = crack_bifid(processed_text)
        return restoreFormatting(deciphered_text, formatIndex)
    return "ERROR: No Cipher Entered"
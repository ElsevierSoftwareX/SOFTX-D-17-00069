
import os
import array
import re
from stat import *
import shutil
import sys
import subprocess
import os
from os.path import join, getsize
import md5

sourceDirectory = ".\\DATA\\SRC\\"
encodedDirectory = ".\\DATA\\ENC\\"
qualityMeasureDirectory = ".\\DATA\\QUAL\\"
seqs = range(1, 11)


def calculatemd5 (input):
    if os.path.exists(input):
        m = md5.new()
        m.update(open(input, 'rb').read())
        outFile = open(input+".md5", 'wb')
        outFile.write(m.digest())
    return

def md5OK (input):
    if os.path.exists(input):
        m = md5.new()
        m.update(open(input, 'rb').read())
        if os.path.exists(input+".md5"):
            readmd5 = open(input+".md5", 'rb').read()
            if readmd5 == m.digest():
                return True
            else:
                print(input+"\nerror\n")
                return False
        return False        
    return False

def decHeVC (input, output):
    
    print("decoding..." + input)
    DecoderOutputFile = open(input + "_dec.txt" , 'w')
    pid = subprocess.Popen([".\\SoftwareLibraries\\HM11.1\\bin\\vc10\\Win32\\Release\\TAppDecoder.exe",
                     "-b", input,
                     "-o", output,
                     "-d", "8"
                     ], stdout=DecoderOutputFile).communicate()[0]
    return

def file_len(fname):
    with open(fname) as f:
        for i, l in enumerate(f):
            pass
    return i + 1

def VQMT(SRC_REF, SRC_HRC, width, height, output):
    print("VQMT..." + SRC_REF)
    VQMTOutputFile = open(output + "_vqmt.log" , 'w')
    pid = subprocess.Popen([".\SoftwareLibraries\VQMT_Binaries\Windows_32bits\VQMT.exe",
                SRC_REF,
                SRC_HRC,
                str(height),
                str(width),
                "250",
                "1",
                output,
                "PSNR",
                "SSIM",
                "VIFP"
                ], stdout=VQMTOutputFile).communicate()[0]


for root, dirs, files in os.walk(encodedDirectory):
    for name in files:
        enc=join(root, name)
        if enc.endswith(".265"):
            yuvfilename = name.split(".yuv")[0] + ".yuv"
            width = re.findall("[0-9]+x[0-9]+", enc)[0].split("x")[0]
            height = re.findall("[0-9]+x[0-9]+", enc)[0].split("x")[1]
            srcname = enc.split("_")[0]
            decHeVC (enc, qualityMeasureDirectory+name+".yuv")
            VQMT (sourceDirectory+yuvfilename, qualityMeasureDirectory+name+".yuv", width, height, qualityMeasureDirectory + name)


        
        
        

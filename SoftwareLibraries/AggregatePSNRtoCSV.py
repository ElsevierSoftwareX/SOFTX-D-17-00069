
import os
import array
import re
from stat import *
import shutil
import sys
import subprocess
import getopt
import csv


FRmetricDirectory = ".\\DATA\\QUAL\\"

def is_number(s):
    try:
        float(s)
        return True
    except ValueError:
        return False

def main(argv):

    jobcounter=0
    globalsequencecounter=0
    
    SrcHrcCounter=0
    parCounter=0
    fullOutput = open(FRmetricDirectory+"FRmetricsFrameByFrame.txt", "wb")
    fullOutputWriter = csv.writer(fullOutput,  delimiter=',')
    smallOutput = open(FRmetricDirectory+"FRmetricsAverage.txt", "wb")
    smallOutputWriter = csv.writer(smallOutput,  delimiter=',')
    
    for root, dirs, encS in os.walk(FRmetricDirectory):
        for enc in encS:
            if enc.endswith(".csv"):
                results = []
                yuvfilename = enc.split(".yuv")[0] + ".yuv"
                resolution = re.findall("[0-9]+x[0-9]+", enc)[0] #         result=960x544
                srcname = enc.split("_")[0]        #                       result=src01
                metric = enc.split("_")[-1][0:-4]  # remove the extension; result=psnr000
                hrcname = enc.split(".yuv_")[1].split(".265")[0] 
                results.append(yuvfilename)
                results.append(resolution)
                results.append(srcname)
                results.append(metric)
                results.append(hrcname)
                #run twice through file because average result goes first in the csv,
                #then results from individual frames 
                with open(root+"\\"+enc, 'rb') as csvfile:
                    reader = csv.reader(csvfile, delimiter=',')
                    for row in reader:
                        if row[0] == "average":
                            results.append(row[1])
                with open(root+"\\"+enc, 'rb') as csvfile:
                    reader = csv.reader(csvfile, delimiter=',')
                    for row in reader:
                        if is_number(row[0]):
                            results.append(row[1])

                
                fullOutputWriter.writerow(results)
                smallOutputWriter.writerow(results[0:6])
                        
                
if __name__ == "__main__":
   main(sys.argv[1:])

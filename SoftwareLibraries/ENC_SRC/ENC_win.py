import os
import array
import re
from stat import *
import shutil
import sys
import subprocess

#Configuration of the environment
SRCdir = ".\\DATA\\SRC\\" #Location where the source video's can be found
ENCdir = ".\\DATA\\ENC\\" #Location where the encoded files are stored
cfgDirectory = ".\\SoftwareLibraries\\ENC_SRC\\cfg\\"
cfgsequenceDirectory = cfgDirectory + "per-sequence\\"
vcodec=".\\SoftwareLibraries\\HM11.1\\bin\\vc10\\Win32\\Release\\TAppEncoder.exe"
vcfg_seq=cfgDirectory+"\\per-sequence\\src01_960x544p25.cfg" #Just an placeholder file, resolution will be changed dynamically
                                        
#Variables over which are iterated
QPs = [26, 32, 38, 46, 500000, 1000000, 2000000, 4000000, 8000000, 16000000, 500001, 1000001, 2000001, 4000001, 8000001, 16000001] #LCULevelRateControls = [0, 1]
DecodingRefreshTypes = [1, 2]
IntraPeriods = [8, 16, 32, 64]
SearchRanges = [64]
SliceArguments = [0, 2, 4, 1500]
InternalBitDepths = [8]
seqs = range(1, 11)
#Three resolution categories are used.
#The resolution of the input defines the number of LCUs in the slice
# SourceWidths =               [960, 1920, 1280]
# SourceHeights =              [544, 1080, 720]
# LCUperSliceDependingOnRes2 = [75, 270, 120]
# LCUperSliceDependingOnRes4 = [34, 130, 60]
ResolutionTuples = [(960,544,75,34),(1920,1080,270,130),(1280,720,120,60)]

TotalNumberEncodes = sys.maxint
if len(sys.argv)== 2:
    TotalNumberEncodes = int(sys.argv[1])
                                            
cnt=0

for seq in seqs:
    for resolution in ResolutionTuples:
        seqName = "src" + str(seq).zfill(2) + "_" + str(resolution[0]) + "x" + str(resolution[1]) + "p25.yuv"
        cfgs = os.listdir(cfgDirectory) 
        for cfg in cfgs:
            if cfg.endswith(".cfg"):
                for QP in QPs:
                    for DecodingRefreshType in DecodingRefreshTypes:
                        for IntraPeriod in IntraPeriods:
                            if IntraPeriod==8 and DecodingRefreshType==2 and cfg[0:-4]=="GOP8":
                                continue
                            for SearchRange in SearchRanges:
                                for InternalBitDepth in InternalBitDepths:
                                    for SliceArgument in SliceArguments:
                                        cnt = cnt + 1
                                        if cnt>TotalNumberEncodes:
                                            sys.exit()
                                        namePrefix = seqName +"_"+cfg[0:-4]+"_"+str(QP)+"_"+str(DecodingRefreshType)+"_"+str(IntraPeriod)+"_"+str(SearchRange)+"_"+str(InternalBitDepth)+"_"+str(SliceArgument)
                                        #RateControl
                                        if QP < 55:
                                            vRateControl="0"
                                        else:
                                            vRateControl="1"
                                        #TargetBitrate
                                        if QP < 55:
                                            vTargetBitrate="0"
                                        else:
                                            vTargetBitrate=str(QP)
                                        #LCULevelRateControl
                                        if QP < 55:
                                            vLCULevelRateControl="0"
                                        else:
                                            if QP%2==0:
                                                vLCULevelRateControl="0"
                                            else:
                                                vLCULevelRateControl="1"
                                        #QP
                                        if QP < 55:
                                            vQP=str(QP)
                                        else:
                                            vQP="0"
                                        vDecodingRefreshType=str(DecodingRefreshType)
                                        vIntraPeriod=str(IntraPeriod)
                                        vSearchRange=str(SearchRange)
                                        #SliceMode
                                        if SliceArgument==0:
                                            vSliceMode="0"
                                        else:
                                            if SliceArgument==1500:
                                                vSliceMode="2"
                                            else:
                                                vSliceMode="1"
                                        #SliceArgument
                                        if SliceArgument==0:
                                            vSliceArgument="0"
                                        else:
                                            if SliceArgument==1500:
                                                vSliceArgument="1500"
                                            else:
                                                if SliceArgument==2: #2 slices
                                                    vSliceArgument=str(resolution[2])
                                                else: # 4 slices
                                                    vSliceArgument=str(resolution[3])
                                        vInternalBitDepth=str(InternalBitDepth)
                                        vSourceWidth=str(resolution[0])
                                        vSourceHeight=str(resolution[1])
                                        vbitstreamFile=ENCdir+str(namePrefix)+".265"
                                              
                                        vcfg=cfgDirectory+cfg                                                
                                        vinputVideoFile=SRCdir+seqName
                                        
                                        subprocess.call([vcodec, "-c", vcfg, "-c", vcfg_seq, \
                                                         "--RateControl="+vRateControl, "--TargetBitrate="+vTargetBitrate, \
                                                         "--LCULevelRateControl="+vLCULevelRateControl, "--DecodingRefreshType="+vDecodingRefreshType, \
                                                         "--IntraPeriod="+vIntraPeriod, "--SearchRange="+vSearchRange, \
                                                         "--SliceMode="+vSliceMode, "--SliceArgument="+vSliceArgument, \
                                                         "--InternalBitDepth="+vInternalBitDepth, "--SourceWidth="+vSourceWidth, \
                                                         "--SourceHeight="+vSourceHeight, "-q", vQP, \
                                                         "-b", vbitstreamFile, "-o",vbitstreamFile+".recon.yuv" , "-i", vinputVideoFile, \
                                                         "--SEIpictureDigest=1"])
                    
                    
    
        
                
        
        

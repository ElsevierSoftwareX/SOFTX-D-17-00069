import numpy
#import numpy as np
#import matplotlib.pyplot as plt

import sys

if len(sys.argv)!=2 and len(sys.argv)!=3:
	print >> sys.stderr, "Usage: %s inputfile_with_comma [srcXX]" % (sys.argv[0])
	sys.exit(1)
	
fname_in=sys.argv[1]
if fname_in=="stdin":
	f_in=sys.stdin
else:
	f_in=open(fname_in,"r")

if len(sys.argv)==3:
	filterstring=sys.argv[2]
else:
	filterstring=""

x=[]
y=[]
line=f_in.readline()
while line:
	if line[0]!="#":
		if filterstring in line:  # Consider only strings which contain the filterstring
			vec=line.split(',')
			xn=float(vec[5])-float(vec[6]) # PSNR_G-PSNR_A
			yn=float(vec[8])*float(vec[8]) # Squared  (\sigma^2_PSNR)
			x.append(xn)
			y.append(yn)
	line=f_in.readline()
f_in.close()

y_sq = sum([ y[i]*y[i] for i in range(0,len(x)) ])
yx = sum( [ y[i]*x[i] for i in range(0,len(x)) ] )
a = y_sq / float(yx)

x_max=5
print "#slope %f" % (a)  # Interpolation parameter
print "%f,%f" % (0, a*0)  # first point of the interpolation line to plot
print "%f,%f" % (x_max, a*x_max)  # second point of the interpolation line to plot



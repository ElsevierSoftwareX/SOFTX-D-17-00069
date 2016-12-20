# 
# This file is part of ReproducibleQualityResearch.
# 
# ReproducibleQualityResearch is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License (LGPL) as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# ReproducibleQualityResearch is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with Foobar.  If not, see <http://www.gnu.org/licenses/>.
# 
# Author of this file: Enrico Masala  <masala _at polito it>
# Dec 15, 2016
# 

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



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
# GNU Lesser General Public License (LGPL) for more details.
# 
# You should have received a copy of the GNU Lesser General Public License (LGPL)
# along with ReproducibleQualityResearch.  If not, see <http://www.gnu.org/licenses/>.
# 
# Author of this file: Enrico Masala  <masala _at polito it>
# Dec 15, 2016
# 


import sys
import math

frame_num=250

def read_data(fname, isHeaderPresent=False):
	f=open(fname,"r")
	data=[]
	if isHeaderPresent:
		line_header=f.readline()
	else:
		line_header=""
	line=f.readline()
	while line:
		data.append(line.strip())
		line=f.readline()
	f.close()
	return line_header,data


###############################
# main
###############################

if len(sys.argv)!=4:
	print >> sys.stderr, "Usage: %s fname.csv fname_HRCs_to_filter fileout.csv" % (sys.argv[0])
	print >> sys.stderr
	sys.exit(1)
	
fname=sys.argv[1]
fname_filter=sys.argv[2]
foutname=sys.argv[3]


data_header,data=read_data(fname, True)

data_header_HRCs,HRCs=read_data(fname_filter, False)

HRCs_keys={}
for i in range(len(HRCs)):
	k=HRCs[i].replace("yuv_","")
	HRCs_keys[k]=1 # Dummy value


fout=open(foutname, "w")
fout.write(data_header)

for i in range(len(data)):
	v=data[i].split(",")  
	HRC=v[4].strip() # v[4] is the HRC name
	if HRC in HRCs_keys:
		print >> fout, "%s" % (data[i])

fout.close()


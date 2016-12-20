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

def read_data(fname, metric):
	data={}
	f=open(fname,"r")
	line_header=f.readline()
	line=f.readline()
	while line:
		if metric in line:
			v=line.split(',')
			sourceyuv=v[0]
			resolution=v[1]
			src=v[2]
			metric=v[3]
			hrc=v[4]
			#avg=float(v[5])  # Note this removes the trailing \n

			list_val=[]
			list_contains_infinite_values=False
			for i in range(frame_num):
				try:
					# +6  (element [5] is the average of the remaining ones)
					val=float(v[i+6]) # float automatically removes trailing \n on the last element
				except ValueError:
					# Note that float does not handle the "1.#INF00" constant, it has to be handled manually
					#print v[i+6]
					#sys.exit()
					val='1.#INF00'
					list_contains_infinite_values=True
				list_val.append(val)

			#key= "%s,%s,%s" % (resolution,src,hrc)
			key= "%s,%s,%s,%s" % (sourceyuv,resolution,src,hrc)
			data[key]={'list':list_val,'infinite_values':list_contains_infinite_values}

		line=f.readline()
	f.close()
	return line_header,data



###############################
# main
###############################

if len(sys.argv)!=4:
	print >> sys.stderr, "Usage: %s fname.csv newMetricID fileout" % (sys.argv[0])
	print >> sys.stderr
	sys.exit(1)
	
fname=sys.argv[1]
metricID="psnr000"
metricIDnew=sys.argv[2]
foutname=sys.argv[3]

line_header,data_metricID=read_data(fname, metricID)
#print line_header
#print "Source, Resolution, Src, Metric, HRC, Avg"
print "READ source file %s" % (fname)


fout=open(foutname, "w")

for k in data_metricID:
	list_val = data_metricID[k]['list']
	list_contains_infinite_values = data_metricID[k]['infinite_values']

	if True:
		listmse=[]
		tot=0.0
		for j in range(len(list_val)):
			v=list_val[j]
			if v == '1.#INF00':
				v_mse = 0
			else:
				v_mse = 255.0*255.0/ pow(10, v/10.0)  # Reverse PSNR formula  10*log10 255^2/MSE ->  MSE = 255^2/(10^(PSNR/10))
			v = v_mse
			listmse.append(v)
			tot+=v

		avgmse = tot / float(len(list_val))
 		#final_val = 10.0*math.log10(255.0*255.0/avgmse)  # Compute PSNR from the avg of the MSE
		#final_val_str = "%.6f" % (final_val)
			
	k_split=k.split(',')
	k_source_resolution_src=','.join( k_split[0:3] )
	k_hrc=k_split[3]
	fout.write("%s,%s,%s,%.6f," % (k_source_resolution_src,metricIDnew,k_hrc,avgmse) )
	#for i in range(len(listmse)-1):
	for i in range(len(listmse)-1):
		fout.write("%.6f," % (listmse[i]))
	# +1 to be added, this is not like a for in "C" language where the i has the +1 value at the end!
	fout.write("%.6f\n" % (listmse[i+1]))   # to avoid , at the end and put \n

fout.close()
	

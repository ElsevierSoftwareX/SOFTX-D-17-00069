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

def read_data(fname, metric, isHeaderPresent=False):
	data={}
	f=open(fname,"r")
	if isHeaderPresent:
		line_header=f.readline()
	else:
		line_header=""
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


def variance(lis):
	tot=0.0
	totsq=0.0	
	n=len(lis)
	for i in range(n):
		v=lis[i]
		tot+=v
		totsq+=(v*v)
	var=( totsq - (tot*tot)/n ) / (n-1)
	return var


###############################
# main
###############################

if len(sys.argv)!=4:
	print >> sys.stderr, "Usage: %s fname.csv fname_mse.csv fileout_stddev.csv" % (sys.argv[0])
	print >> sys.stderr
	sys.exit(1)
	
fname=sys.argv[1]
fname_mse=sys.argv[2]
foutname=sys.argv[3]

line_header,data_metricIDpsnr=read_data(fname, "psnr000")
#print line_header
#print "Source, Resolution, Src, Metric, HRC, Avg"
print "READ source file %s" % (fname)
line_header2,data_metricIDmse=read_data(fname_mse, "mse_000")
print "READ source file %s" % (fname_mse)


fout=open(foutname, "w")
fout.write("#Source, Resolution, Src, Metric, HRC, avgpsnr, psnrmse, mean_psnr, stddev_psnr, mean_mse, stddev_mse\n")

cnt=0
for k in data_metricIDpsnr:
	list_psnr = data_metricIDpsnr[k]['list']
	list_mse = data_metricIDmse[k]['list']
	list_contains_infinite_values = data_metricIDpsnr[k]['infinite_values']

	if cnt%1000==0:
		print "%d " % (cnt),  # no \n : show progress
		sys.stdout.flush()

	if not list_contains_infinite_values:

		_psnr=[]
		_mse=[]
		_psnr=list_psnr[:]
		_mse=list_mse[:]

		avgpsnr=sum(list_psnr)/float(len(list_psnr))
		avgmse=sum(list_mse)/float(len(list_mse))
		psnrmse= 10.0*math.log10(255.0*255.0/avgmse)  # Compute PSNR from the avg of the MSE

		mean_psnr=sum(_psnr)/float(len(_psnr))
		stddev_psnr=math.sqrt(variance(_psnr))
		mean_mse=sum(_mse)/float(len(_mse))
		stddev_mse=math.sqrt(variance(_mse))

		k_split=k.split(',')
		k_source_resolution_src=','.join( k_split[0:3] )
		k_hrc=k_split[3]
		fout.write("%s,%s,%s,%.6f,%.6f,%.6f,%.6f,%.6f,%.6f\n" % (k_source_resolution_src,"psnr000_psnrA00",k_hrc,avgpsnr,psnrmse, mean_psnr, stddev_psnr, mean_mse, stddev_mse) )

	cnt+=1

fout.close()


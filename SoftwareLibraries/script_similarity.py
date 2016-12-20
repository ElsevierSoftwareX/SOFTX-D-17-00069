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

import sys
import math

def readfile(fname):
	f_in=open(fname,"r")
	d=[]
	line=f_in.readline()
	while line:
		if line[0]!="#":
			vec=line.split(',')
			xn=float(vec[5])-float(vec[6])
			yn=float(vec[8])*float(vec[8]) # Squared
			d.append( (xn,yn) )
		line=f_in.readline()
	f_in.close()
	return d

def dist_L2(A,B):
	return math.sqrt((A[0]-B[0])*(A[0]-B[0])+(A[1]-B[1])*(A[1]-B[1]))



if len(sys.argv)!=3:
	print >> sys.stderr, "Usage: %s inputfile_with_comma  representativefile_with_comma" % (sys.argv[0])
	sys.exit(1)
	
fname_in=sys.argv[1]
fname_in2=sys.argv[2]

data1=readfile(fname_in)
centroids=readfile(fname_in2)

#print len(data1), len(data2)

n_elem=[0]*len(centroids)
distance=[0.0]*len(centroids)
tot_distance=0
tot_num=0

for i in range(len(data1)):
	if i%1000==0:
		print >> sys.stderr, "%d/%d " % (i,len(data1)),
		sys.stderr.flush()
	mindist=1e9
	point=-1
	for j in range(len(centroids)):
		dist=dist_L2(data1[i], centroids[j])
		if dist < mindist:
			mindist = dist
			point = j
	n_elem[point]+=1
	distance[point]+=mindist
	tot_distance+=mindist
	tot_num+=1

print >> sys.stderr


for j in range(len(centroids)):
	if n_elem[j]!=0:
		distance[j]=distance[j]/n_elem[j]

tot_avg_distance=tot_distance/float(tot_num)
print "#CentroidID num_points avg_distance"
print "#tot_avg_distance %f" % (tot_avg_distance)

for j in range(len(centroids)):
	print "%d,%d,%f" % (j,n_elem[j],distance[j])




import sys

if len(sys.argv)!=3:
	print >> sys.stderr, "Usage: %s inputfile_with_comma outputfile" % (sys.argv[0])
	sys.exit(1)
	
fname_in=sys.argv[1]
fname_out=sys.argv[2]

nam=[]
d=[]
f_in=open(fname_in,"r")
line=f_in.readline()
while line:
	if line[0]!="#":
		vec=line.split(',')
		##n="%s_%s_%s" % (vec[0],vec[1],vec[2]) # Resolution_src_encoding
		n="%s_%s_%s" % (vec[1],vec[2],vec[4]) # Resolution_src_encoding
		v=float(vec[5])-float(vec[6])
		d.append(v)
		nam.append(n)
	line=f_in.readline()
f_in.close()

cnt=len(d)
#d_sorted=sorted(d)
index_sorted=sorted(range(len(d)), key=lambda k: d[k])

step_y=1.0/float(cnt)

f_out=open(fname_out,"w")
for i in range(len(index_sorted)):
	print >> f_out, "%.6f %.6f %s" % ( d[index_sorted[i]], (i+1)*step_y, nam[index_sorted[i]] )
f_out.close()



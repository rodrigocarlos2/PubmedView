#!/usr/bin/env python

import re
import sys
import os
import subprocess
import urllib2


## command line arguments
# taking the filename that contains PMIDs
narg = len(sys.argv)
if narg<2:
	print "...failed! enter pmid filename"
	sys.exit()
else:
	pmids_filename=sys.argv[1]

# PMID: 11063804 .. .NM23.H1 is a gene name but was broken into lines in between.
# this function prohibits this.
def dot_splitter_correction(line):	
	matchobj = re.findall(r'\b([A-Z0-9]+)\.([A-Z0-9]+)\b',line,re.M)
	for m in matchobj:
		if re.search(r'[A-Z]',m[0],re.M) and re.search(r'[A-Z]',m[1],re.M) and re.search(r'[0-9]',m[0],re.M) and re.search(r'[0-9]',m[1],re.M):
			original_m=m[0]+'.'+m[1]			
			replace_m=m[0]+'~+~'+m[1] # dot replaced by ~+~			
			patt_m =original_m
			patt_r = replace_m
			regex = re.compile(patt_m, re.M)
			line=regex.sub(patt_r,line)
	return line

# step-1:
# getting abstract from PUBMED.org

pipe = subprocess.Popen(["perl", "downloadPMID.pl", pmids_filename], stdout=subprocess.PIPE)
result = pipe.stdout.read()
#print result


# step-2:
# parsing the pubmed result into a non-splitted version
x=0
y=0
pmidList=list()
istitle=False
title=""
isabstract=False
abstract="AB  - "
isPT=False # publication type tag PT
isMH=False
PT="PT-"
MH="MH-"
resultlines=result.split('\n')
for line in resultlines:
	if re.search(r'^PMID- ',line,re.M|re.I):
		if isabstract or isPT:
			isabstract=False
			PT=re.sub(r'~@~$','',PT)
			MH=re.sub(r'~@~$','',MH)
			pmidList.append(str(pmid.strip())+'~#~'+title+'~#~'+abstract+'~#~'+PT+'~#~'+MH)
			PT="PT-"
			MH="MH-"
			title='TI  - '
			abstract='AB  - '
		pmid=line.strip().split('PMID-')[1]		
		#print pmid
		x+=1
	elif re.search(r'^TI\s+-',line,re.M|re.I):
		istitle=True
		title=line.strip()#.split('TI  - ')[1]
		#print title
	elif re.search(r'^AB\s+-',line,re.M|re.I):
		istitle=False
		isabstract=True
		abstract=line.strip()#.split('AB  - ')[1]
		#print title
	elif re.search(r'^PT\s+-',line,re.M|re.I):
		#print line
		isabstract=False
		isPT=True
		PT+=line.strip().split('PT  - ')[1]+'~@~'
	elif re.search(r'^MH\s+-',line,re.M|re.I):
		#print line
		isabstract=False		
		MH+=line.strip().split('MH  - ')[1]+'~@~'
	else:
		if istitle:
			title+=' '+line.strip()
		elif isabstract:
			abstract+=' '+line.strip()
if isabstract or isPT:
	isabstract=False
	PT=re.sub(r'~@~$','',PT)
	MH=re.sub(r'~@~$','',MH)
	#print title
	pmidList.append(str(pmid.strip())+'~#~'+title+'~#~'+abstract+'~#~'+PT+'~#~'+MH)
	PT="PT-"
	MH="MH-"
	title='TI  - '
	abstract='AB  - '

# step-3:
for abst in pmidList:
	pieces=abst.split('~#~')

	print "PMID-"+pieces[0]
	p1 = dot_splitter_correction(pieces[1])
	print p1
	p2 = dot_splitter_correction(pieces[2])
	print p2
	p3 = pieces[3]
	print p3
	p4 = pieces[4]
	print p4
	print ""



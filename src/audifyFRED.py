#!/usr/bin/env python
import numpy as np
from scipy import signal
import scipy.io.wavfile
import argparse
import csv
import sys
import os
import math


# Define command line arguments
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", default = "input.csv",
                    help = "Name of input CSV data file.")
parser.add_argument("-o", "--output", default = "", 
                    help = "Name of output file. If none specfied will have same name as input but with .wav extension. Any path is ignored. Change the desired output path with the --dir argument") 
parser.add_argument("-d", "--dir", default = "wavs", 
					help = "Name of directory where output should be placed.")
parser.add_argument("-fs", "--FS", default = 4000, type=int,
					help = "Specify the sample rate of the data file.")

args = parser.parse_args()    


if args.input == "input.csv":
	parser.print_help()
	parser.exit()

print args.dir


# Construct output file name parts from input filename if exists, otherwise from output filename argument
if args.output == "":
	outFilnam = os.path.split(args.input)[1].split(".")[0]
else:
	outFilnam = os.path.split(args.output)[1].split(".")[0]

outPath = args.dir # Always use this rather than path from args.output

if args.dir != "" and not os.path.exists(args.dir):
	os.makedirs(args.dir)
if outPath != "": # Only add slash if final path not null
	outPath = outPath + "/"
	
print outPath + ":" + outFilnam

	
	
print "START"
# the double ** is a power operator, i.e. 2^15
convert_16_bit = float(2**15)

samples =np.array([])
rawSamples =np.array([])
timeStamps = np.array([])
intervals = np.array([])


# open input file
ctr = 0.
with open(args.input, 'rU') as csvfile:
    reader = csv.reader(csvfile, delimiter='\t')
    for row in reader:
    	samples = np.append(samples, float(row[0]))   





rawSamples =samples /2.0 # Needed for DSSon MATLAB scripts

# Write samples out as an audio buffer of length len(samples) at args.rate
raw = np.int16( rawSamples * convert_16_bit)
outfil = outPath + outFilnam + ".wav"
print outfil
scipy.io.wavfile.write(outfil, 44100, raw)
	


print "STOP"
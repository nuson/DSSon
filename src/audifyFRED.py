#!/usr/bin/env python
import numpy as np
from scipy import signal
import scipy.io.wavfile
import argparse
import csv
import sys
import os
import math
import matplotlib.pyplot as plt

# Define command line arguments
parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input", default = "input.csv",
                    help = "Name of input CSV data file.")
parser.add_argument("-o", "--output", default = "", 
                    help = "Name of output file. If none specfied will have same name as input but with .wav extension. Any path is ignored. Change the desired output path with the --dir argument") 
parser.add_argument("-d", "--dir", default = "wavs", 
					help = "Name of directory where output should be placed.")
parser.add_argument("-pd", "--plots", default = "figs", 
					help = "Name of directory where plots should be placed.")
parser.add_argument("-D", "--Debug", action='store_true', default=False,
					help = "Turn on print statements for debugging.")
parser.add_argument("-f", "--fade", default = 0, type=int,
					help = "Add an n sample fade-in/out to prevent non-zero crossing clipping. Seems to work well if n is at least 50.")	
parser.add_argument("-fs", "--FS", default = 4000, type=int,
					help = "Specify the sample rate of the data file.")
parser.add_argument("-n", "--noskip", action='store_true', default=False,
					help = "Do not skip header row in spreadsheet. Off by default, use -n or --noskip if no header row present.")
parser.add_argument("-s", "--separator", choices=['tab', 'comma'], default ="tab", 
					help = "Specify the type of input file: comma separated or tab separated. Default is tab.")		
parser.add_argument("-m", "--mono", action='store_true', default=False,
					help = "Specify mono output. Default is stereo.")
parser.add_argument("-S", "--Stats", choices=['quit', 'cont', 'none'], default = 'none',
					help = "Show basic sampling stats of the data file. Quit after if 'quit', continue with audio processing if 'cont'. If 'none', then show no stats.")	
parser.add_argument("-r", "--rate", default=44100, type=int,
					help = "Resample the generated audio to the sample rate specified by the argument's value. Default = 44100 which results in resampling. Sample usage: sigproc -r 44100 would generate a 44.1 kHz audio file.")
parser.add_argument("-R", "--Raw", default=0, type=int,
					help = "Write the input data to a wave file such that each value becomes a sample using RAW as sample rate. Length of file will be number of data points.")
parser.add_argument("-t", "--transform", default=0, type =int,
                    help = "Shift the fequency of the signal up by n Hz.")
parser.add_argument("-c", "--constant", default =0.0, type =float,
                    help = "Exponentially encode the values of the signal by c octaves. Turns output into auditory graph. Default is 0.")			
parser.add_argument("-p", "--plot", action='store_true', default=False,
					help = "Plot the input data file. Default action = no plot.")
parser.add_argument("-x", default = "x", help = "Legend for x axis of plot.")
parser.add_argument("-y", default = "Frequency in Hz", help = "Legend for y axis of plot.")

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


if args.plots != "" and not os.path.exists(args.plots):
	os.makedirs(args.plots)

if args.plots != "":
	outFigPath = args.plots + "/"
else:
	outFigPath = ""
	
	
	
print "START"
# the double ** is a power operator, i.e. 2^15
convert_16_bit = float(2**15)

samples =np.array([])
rawSamples =np.array([])
timeStamps = np.array([])
intervals = np.array([])
ssb = np.array([])

if args.separator == 'tab':
	delim = '\t'
else:
	delim = ','
# open input file
ctr = 0.
with open(args.input, 'rU') as csvfile:
    reader = csv.reader(csvfile, delimiter=delim)
    if args.noskip is False:
    	next(reader, None)  # skip the headers
    for row in reader:
    	samples = np.append(samples, float(row[0]))
    	ctr +=1.0
    	timeStamps = np.append(timeStamps, ctr /args.FS)
    	#samples = np.append(samples, float(row[1].split(';')[0]))
        #timeStamps = np.append(timeStamps, float(row[0])/10.0)
    


# Calculate sample rate of data file
last = 0.0
count = 0
duration = 0.0
for timeStamp in range (len(timeStamps)): 
	count += 1
	duration += (timeStamps[timeStamp] - last)
	intervals = np.append(intervals, timeStamps[timeStamp] - last)
	last = timeStamps[timeStamp]

# Calculate average sampling interval of the data
t=0.0
for n in range (len(intervals)):
	t+=intervals[n]
sampleRate = float(count/duration)
print "Sample Rate: " + str(sampleRate)
sampleInterval = float(1/sampleRate)
if args.Stats != 'none':
	print 'File:              ', args.input
	print 'Num. data values:  ', count
	print 'Duration:          ', duration, 's.'
	print 'Sample rate:       ', count/duration, 'Hz'
	print 'Sampling interval: ', sampleInterval, 's.'
	print 'Average interval:  ', t/len(intervals), 's.'	
	print 'Max:               ', max(samples)
	print 'Min:               ', min(samples)
	if args.Stats == 'quit':
		sys.exit()

# Plot the input data
if args.plot:
	fig = plt.figure()
	ax0 = fig.add_subplot(211)
	ax0.set_ylim([0,1.0])
	ax1 = fig.add_subplot(211)
#	ax0.plot(t, samples, label=args.input, linewidth=0.1)
	t = np.arange(len(samples))
	ax0.autoscale(enable=True, axis='both', tight=True)
	ax1.fill_between(t, 0, 0.2, facecolor='yellow', alpha=0.2)
	yMax = 1.0
	if max(samples) > 1.0:
		yMax = max(samples)
	ax1.fill_between(t, 0.6, yMax, facecolor='yellow', alpha=0.2)
	ax0.plot(t, samples, label=args.input, color='k', linewidth=0.1)
#	ax0.plot([0, 590], [0.2, 0.2], 'k-', lw=0.1)
#	ax0.plot([0, 590], [0.6, 0.6], 'k-', lw=0.1)
	#plt.setp(line, linewidth=0.5)

	xlabel = args.x
	if xlabel == "x":
		xlabel = "Samples (fs=" + str(args.FS) + " Hz)"
	ax0.set_xlabel(xlabel)
	ax0.set_ylabel(args.y)
	ax0.legend()
	fig.savefig(outFigPath + outFilnam + ".pdf", bbox_inches='tight')
	#plt.show()
	

# Scale 
oldMax = max(samples)
oldMin = min(samples)
oldRange = oldMax - oldMin

# Scale to audio signal range (-1..1)
newMax = 0.98
newMin = -0.98
newRange = newMax - newMin

# scale to -1.0 -- 1.0
#samples = (((samples - oldMin) * newRange) / oldRange) + newMin
rawSamples =samples /2.0 # Needed for Robert's new aud patch

samples = np.interp(samples, [min(samples),max(samples)], [newMin,newMax])


# Write samples out as an audio buffer of length len(samples) at args.rate
if args.Raw > 0:
	raw = np.int16( rawSamples * convert_16_bit)
	outfil = outPath + outFilnam + "raw_" + str(args.Raw) + ".wav"
	print outfil
	

#
#	outfil = args.output
#	if outfil == "":
#		outfil = args.input.split('.')[0] + "raw_" + str(args.Raw) + ".wav"
	scipy.io.wavfile.write(outfil, args.Raw, raw)
	



if args.rate > 0:
	print 'Resampling'
	sampleRate = args.rate
	samps = int(math.ceil(duration))* args.rate    # Number of samples to downsample
	print 'Num Samples:       ',samps
	print 'Duration:          ',duration, "s."
	samples = signal.resample(samples, samps)

duration = len(samples)/sampleRate
numsamples = sampleRate*duration
t = np.arange(numsamples) / float(sampleRate)
c = np.linspace(args.constant, args.constant, num=numsamples)




# SSB modulation

deltaf = args.transform
analytical = signal.hilbert (samples)
if args.Debug:
	print "Original", samples
	print "Analytical", analytical
	print "Imag", np.imag(analytical)
# ---
# Basic frequency shifting without the instantaneous frequency modulation
#ssb= samples * np.cos(2.0*np.pi*deltaf*t) \
#- np.imag(analytical)* np.sin(2.0*np.pi*deltaf*t)
# ---

# --- Add the instantaneous frequency modulation for auditory graphing
phi = np.cumsum(2.0*np.pi*deltaf*np.power(2.0, c * samples)/sampleRate)
ssb= samples * np.cos(phi) - np.imag(analytical)* np.sin(phi)

#Rescale to remove clipping
ssb = np.interp(ssb, [min(ssb),max(ssb)], [newMin,newMax])
#ssb = ssb - np.average(ssb)
# Remove DC offset
av = np.mean(ssb)
for ctr in range(len( ssb)):
	if ssb[ctr] - av > -1: #Prevent values going below -1
		ssb[ctr] -=  av


# scale to -32768 -- 32767
ssb = np.int16( ssb * convert_16_bit)

# Add fade-in/out
if args.fade >0 :
	fade = 0.0
	for ctr in range(args.fade):
		ssb[ctr]*=fade
		ssb[len(ssb)-ctr-1] *= fade
		fade += 1.0/args.fade
		
if args.Debug:
	print 'First 50 samples:  ', ssb[:50]
	print 'Last 50 samples:   ', ssb[-50:]

	
# Write modulated signal to outputfile
#outfil = args.output
#if outfil == "":
#	fileparts = os.path.split(args.input)
outfil = outPath + outFilnam + \
		"_s_"+str(sampleRate)+"_f_"+str(args.transform)+ \
		"_c_"+str(args.constant)+".wav"

scipy.io.wavfile.write(outfil,
    sampleRate, ssb)


print "STOP"
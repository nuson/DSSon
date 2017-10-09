# DSSon &mdash; Direct Segmented Sonification

In sonification and audification, signals, data sets, or selected features of data sets, are mapped to audio signals to create an auditory display of the data. Audification translates the the original signal’s data points into digital audio samples and the length of the resultant auditory display is determined by the playback rate. 

Like audification, auditory graphs maintain the temporal relationships of one-dimensional data whilst using parameter mappings found in sonification to represent the ordinate values, typically via a data-to-frequency mapping. The advantage of direct approaches like audification and auditory graphs is that the data stream is presented ‘as is’ without the imposed interpretation or accentuation of particular features found in more indirect approaches. 

However, data streams can often be subdivided into short non-overlapping segments of varying length such that each segment encapsulates a discrete unit of domain-specific significant information and current direct approaches cannot represent these. Direct Segmented Sonification (DSSon) is a way of maintaining the directness of audification and the source signal’s original time regime while highlighting the segments’ data distribution as individual sonic events. 

Using a data stream segmentation derived from domain-specific knowledge and a modified auditory graph approach, DSSon is able to present each segment as its own auditory gestalt while retaining the overall temporal regime and relationships of the source signal. Furthermore, as the segment sonification method is structurally decoupled from the formation of the final sound stream, the playback speed of the entire DSSon signal can be set independent of the length of the individual sonic events offering a range of time compression/stretching factors and thereby high flexibility for zooming into or out of the data. DSSon offers application-dependent flexibility while maintaining a high degree of directness so that it lets the data ‘speak’ for themselves.

## Contents of the repository
```
/ [root]    
├── data
│   ├── LabChart - the original LabChart data files
│   │   ├── DA1.adicht
│   │   ├── DA2.adicht
│   │   └── DB1.adicht
│   ├── audified - 44100 kHz audifications of the txt files in /data/txt
│   │   ├── DA1.wav
│   │   ├── DA2.wav
│   │   └── DB1.wav
│   └── txt - data files of regions extract from the LabChart files using LabChartView
│       ├── DA1.txt
│       ├── DA2.txt
│       └── DB1.txt
├── examples - the sonifications of the files in data/txt using the MATLAB DSSon scripts
│   ├── DSSON_ADV_B.wav
│   ├── DSSON_Basic_A_e.wav
│   ├── DSSON_Basic_A_n.wav
│   ├── DSSON_Basic_B.wav
│   ├── DSSON_ITR_A_e.wav
│   └── DSSON_ITR_B.wav
└── src - DSSon MATLAB scripts and the Python script to audify the data files
    ├── DSSon_ADV_Model.m
    ├── DSSon_Basic_Model.m
    ├── DSSon_ITR_Model.m
    └── audifyFRED.py    
```

| Audio File | Description |
| ---------- | ----------- |
| 1 `examples/DSSon_Basic_A_n.wav` | M1, user A &mdash; novice|
| 2 `examples/DSSon_Basic_A_e.wav` | M1, user A &mdash; experienced |
| 3 `examples/DSSon_Basic_B.wav` | M1, user B &mdash; novice |
| 4 `examples/DSSON_ITR_A_e.wav` | M2, user A &mdash; experienced |
| 5 `examples/DSSON_ITR_B.wav` | M2, user B &mdash; novice |
| 6 `examples/DSSon_ADV_A_e.wav` | M3, user A &mdash; experienced "
| 7 `examples/DSSON_ADV_B.wav` | M3, user B &mdash; novice | 
| ---------- | ----------- |
|Models: M1 = basic model; M2 = individual target range model; M3 = advanced model|
|Data files used: user A, novice = DA1; user A, experienced = DA2; user B, novice = DB1 |


## Running it 
1. The original data recorded by LabChart can be found as LabChart .adicht files in 
the folder `data/LabChart`. Data can be extracted from these files by downloading and
installing the free [LabChart Reader](https://www.adinstruments.com/products/labchart-reader).
However, it has no export function so the data need to be resampled and then copied to
a text document and formatted from there.
2. The folder `data/txt` contains text data files which are extracts of the .adicht files
which have been sampled at 100 Hz and which were used as the basis for the audified versions
found in `data/audified`. To generate the audified files, invoke the `audifyFRED.py`
script as follows:

    `python audifyFRED.py -i user.txt -fs 100` where user.txt is the name of the input data file

3. Once the audified files have been generated, the DSSon method can be applied using
the MATLAB scripts in `src`.  



## Authors  
* [**Paul Vickers**](https://paulvickers.github.io)
* [**Robert Höldrich**](http://iem.kug.ac.at/en/people.html?tx_kugpeople_pi1%5Bperson_nr%5D=50114&cHash=eb4d7486e953326e239071165ea47ccf)
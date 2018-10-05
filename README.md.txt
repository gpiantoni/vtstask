TASKS FOR THE VIBROTACTILE STIMULATOR IN MATLAB

This folder contains the code for the vibrotactile stimulator (VTS) in MATLAB.
It works through the following steps 

1. The main module is the VTS_Design.m module, in which the following parameters 
will have to be specified:

- devices: The NIDAQ devices used to control the stimulator
- nrOutputs: number of stimulators used in the experiments
- fingers: number of fingers the stimulators will be connected to
- PORT: the serial port to get/send signals through. If not available it will 
	also run just fine.
- daq: specify the name of a single daq device

2. For the signal to be sent to the stimulators you can set the duration, 
   amplitude and frequency in Hz.

3. All channels specified in nrOutputs will be added to the session.

4. It will try to open the serial port. If not available, it will set the serialport 
   to 0.

5. It will run the experiments, explained below.

6. After the experiments are run, it will close the serial port.

There are 4 experiments that can be run, which are in the Experiments folder:

- stimAll will stimulate all the stimulators specified in nrOutputs at once
- stimSeq will stimulate the individual stimulators in sequence reversing at a 
  specified location.
- stimPerFinger will stimulate per finger in sequence, after which it will go in 
  reverse
- stimWithin will stimulate the individual stimulators in sequence within a finger.

The signals send through the serial port are as follows:

signal | experiment          | description
10     | stimAll             | start stimulating all outputs
----------------------------------------------------------------
11     | stimSeq             | start stimulating stimulator 1
12     | stimSeq             | start stimulating stimulator 2
13     | stimSeq             | start stimulating stimulator 3
14     | stimSeq             | start stimulating stimulator 4
15     | stimSeq             | start stimulating stimulator 5
16     | stimSeq             | start stimulating stimulator 6
17     | stimSeq             | start stimulating stimulator 7
18     | stimSeq             | start stimulating stimulator 8
19     | stimSeq             | start stimulating stimulator 9
20     | stimSeq             | start stimulating stimulator 10
21     | stimSeq             | start stimulating stimulator 11
22     | stimSeq             | start stimulating stimulator 12
23     | stimSeq             | start stimulating stimulator 13
24     | stimSeq             | start stimulating stimulator 14
25     | stimSeq             | start stimulating stimulator 15
26     | stimSeq             | start stimulating stimulator 16
27     | stimSeq             | start stimulating stimulator 17
28     | stimSeq             | start stimulating stimulator 18
29     | stimSeq             | start stimulating stimulator 19
30     | stimSeq             | start stimulating stimulator 20
----------------------------------------------------------------
31     | stimPerFinger       | start stimulating finger 1
32     | stimPerFinger       | start stimulating finger 2
33     | stimPerFinger       | start stimulating finger 3
34     | stimPerFinger       | start stimulating finger 4
35     | stimPerFinger       | start stimulating finger 5
36     | stimPerFinger       | start stimulating finger 6
37     | stimPerFinger       | start stimulating finger 7
38     | stimPerFinger       | start stimulating finger 8
39     | stimPerFinger       | start stimulating finger 9
40     | stimPerFinger       | start stimulating finger 10
----------------------------------------------------------------
41     | stimWithin          | start stimulating stimulator 1
42     | stimWithin          | start stimulating stimulator 2
43     | stimWithin          | start stimulating stimulator 3
44     | stimWithin          | start stimulating stimulator 4
45     | stimWithin          | start stimulating stimulator 5
46     | stimWithin          | start stimulating stimulator 6
47     | stimWithin          | start stimulating stimulator 7
48     | stimWithin          | start stimulating stimulator 8
49     | stimWithin          | start stimulating stimulator 9
50     | stimWithin          | start stimulating stimulator 10
51     | stimWithin          | start stimulating stimulator 11
52     | stimWithin          | start stimulating stimulator 12
53     | stimWithin          | start stimulating stimulator 13
54     | stimWithin          | start stimulating stimulator 14
55     | stimWithin          | start stimulating stimulator 15
56     | stimWithin          | start stimulating stimulator 16
57     | stimWithin          | start stimulating stimulator 17
58     | stimWithin          | start stimulating stimulator 18
59     | stimWithin          | start stimulating stimulator 19
60     | stimWithin          | start stimulating stimulator 20
----------------------------------------------------------------
150    | all experiments     | stop stimulating

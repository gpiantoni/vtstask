TASKS FOR THE VIBROTACTILE STIMULATOR IN MATLAB

This folder contains the code for the vibrotactile stimulator (VTS) in MATLAB.
It works through the following steps 

1. The main module is the VTS_stim.m module, in which the following parameters 
will have to be specified:

	* For the experiment:
		- devices: the NIDAQ devices used to control the stimulators
		- nrOutputs: number of stimulators used in the experiment
		- PORT: the serial port to get/send signals through. If not available it will 
			also run just fine. You can start the experiment manually.
		- daq: specify the name daq device(s)

	* For the logger:
		- subject: The name of the subject
		- logdir: Path to directory where log files should be saved.

   * For the experiment design:
      -fname: The .txt file were your design is specified (see below).

2. For the signal to be sent to the stimulators you can set parameters in an experiment design .txt file. 

   For an example of such a .txt file and an explanation of the parameters,
    open a .txt file in current folder that starts with 'design_'.
   		
3. All channels specified in nrOutputs will be added to the session.

4. It will try to open the serial port. If not available, it will set the serialport 
   to 0. 

5. It will run the experiments, explained below.

6. Thereafter it logs the start time delay (not reliable)

7. After the experiments are run, it will close the serial port.

All experiments go through the same process:

1. The logger indicates the experiment starts.
2. With the parameters specified in your experiment design .txt file a stimulation matrix
   will be created using the file createStimMat.m.  
3. If an input serial port is present, the program waits for a trigger to start the experiment.
4. After the program starts, the start time delay is saved (not reliable). After the experiment is done it is logged. 

The important functions and modules are commented. Some old functions and modules can be found in the 
'Old' map. The previous version of the VTS build by Martijn Thio can be found in the 'Martijn' map. In the ecog map you find 
3 experimental designs for ecog and a trigger test script. 
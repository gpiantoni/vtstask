TASKS FOR THE VIBROTACTILE STIMULATOR IN MATLAB

This folder contains the code for the vibrotactile stimulator (VTS) in MATLAB.
It works through the following steps 

1. The main module is the VTS_Design.m module, in which the following parameters 
will have to be specified:

	* For the experiment:
		- devices: The NIDAQ devices used to control the stimulator
		- nrOutputs: number of stimulators used in the experiments
		- fingers: number of fingers the stimulators will be connected to
		- PORT: the serial port to get/send signals through. If not available it will 
			also run just fine.
		- daq: specify the name of a single daq device

	* For the logger:
		- subject: The name of the subject
		- logdir: Path to directory where log files should be saved.

2. For the signal to be sent to the stimulators you can set the following 
   parameters.

   - amplitude: At the moment the amplitude for each experiment is the same.
   - duration: There are two different durations, one for stimulating all fingers
   		and one for stimulating sequentially. You can set the total time of 
   		stimulation by setting `stimdur_total_(all/fing)`. The interval of stimulation
   		(so X ms on, Y ms off) can be set '`stimdur_(all/fing)_on` and 
   		`stimdur_(all/fing)_off` respectively.
   - frequency: There are three different frequencies for the sequential stimulation
   		experiments, namely 30, 110 and 190 Hz. 
   		
   		
3. All channels specified in nrOutputs will be added to the session.

4. With the parameters specified above, it will create a single signal for each of the 
   experiments using `createSignal`. This signal will be used to create the stimulation
   matrix. 

5. The files used for the experiments are loaded. For the first this is a file containing
   the onsets to stimulate the outputs, which are transformed to a list `hrf_onsets`.
   You can also just use a list specified within MatLab as onsets, see `onsets`. The second
   file that is loaded is a text file containing the random order in which the fingers are
   stimulated sequentially.

6. It will try to open the serial port. If not available, it will set the serialport 
   to 0.

5. It will run the experiments, explained below.

6. After the experiments are run, it will close the serial port.

At the moment there are 4 experiments, with the last three being identical except for their
frequency. All experiments go through the same process:

1. The logger indicates the experiment starts and logs all the variables used.
2. The stimulation matrix is created using the signal created at the beginning of the program. Examples of
	a function creating such a matrix can be found in creatStimFingMat.m.
3. If an input serial port is present, the program waits for a trigger to start the experiment.
4. After the program starts, the logger logs the initial delay due to buffering and when each 
   output is stimulated. NOTE: the logger runs parralel to but independently from the VTS.
   However, the logger seems to be accurate enough.

The important functions and modules are commented. Some old functions and modules can be found in the 
'deprecated' map. 



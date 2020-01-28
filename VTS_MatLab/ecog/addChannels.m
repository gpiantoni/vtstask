function addChannels(session, nrChannels, outName, outType)
% Function that adds all the channels to the DAQ session
% 
% addChannel(session, nrChannels, outName,outType)
%- session: The DAQ session it needs to be added to
%- nrChannels: Number of stimulators
%- outName: Name of the output, default
%- outType: Type of output, default = Voltage


if nargin < 4
    outType = 'Voltage';
end

        
    
for i = 0: nrChannels-1
    ao = strcat('ao', int2str(i));
    addAnalogOutputChannel(session, outName, ao, outType);
end

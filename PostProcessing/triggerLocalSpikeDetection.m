function [stimulatePeak,stimulatePeakLocs,triggerPeak,triggerPeakLocs] = triggerLocalSpikeDetection(triggerData,stimulateData,thresholdTrigger,thresholdStimulation,minDistance,skipWindow)
%triggerLocalSpikeDetection Detect spike on stimulate data after
%triggerData is triggered by spike detection.
%   [stimulatePeak,stimulatePeakLocs,triggerPeak,triggerPeakLocs] = triggerLocalSpikeDetection(triggerData,stimulateData,thresholdTrigger,thresholdStimulation,minDistance,skipWindow)

if nargin < 6
    skipWindow = 0;
end

stimulatePeak = zeros(0,1);
stimulatePeakLocs = zeros(0,1);

[triggerPeak,triggerPeakLocs] = triggerSpikeDetection(triggerData,thresholdTrigger,minDistance); % peaks and locs of trigger pulses

[stimulatedPulses,stimulatedPulsesLocs] = findpeaks(stimulateData,'minPeakHeight',thresholdStimulation); % all the peaks and locs of spikes after pulses

for i = 1:length(triggerPeak)
    stimulatePeak = [stimulatePeak; stimulatedPulses(find(stimulatedPulsesLocs > (triggerPeakLocs(i)+skipWindow),1))]; % value of the first peak after artefact
    stimulatePeakLocs = [stimulatePeakLocs; stimulatedPulsesLocs(find(stimulatedPulsesLocs > (triggerPeakLocs(i)+skipWindow),1))]; % location of the first spike after artefact
end


end


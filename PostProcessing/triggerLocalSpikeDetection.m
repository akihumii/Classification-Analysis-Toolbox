function [stimulatePeak,stimulatePeakLocs] = triggerLocalSpikeDetection(triggerData,stimulateData,thresholdTrigger,thresholdStimulation,minDistance,skipWindow,stimulatePeak,stimulatePeakLocs)
%triggerLocalSpikeDetection Detect spike on stimulate data after
%triggerData is triggered by spike detection.
%   [stimulatePeak,stimulatePeakLocs] = triggerLocalSpikeDetection(triggerData,stimulateData,thresholdTrigger,thresholdStimulation,minDistance,skipWindow,stimulatePeak,stimulatePeakLocs)

if nargin < 6
    stimulatePeak = zeros(0,1);
    stimulatePeakLocs = zeros(0,1);
    skipWindow = 0;
end

[triggerPulses,triggerPulsesLocs] = triggerSpikeDetection(triggerData,thresholdTrigger,minDistance); % peaks and locs of trigger pulses

[stimulatedPulses,stimulatedPulsesLocs] = findpeaks(sign * stimulateData,'minPeakHeight',thresholdStimulation); % all the peaks and locs of spikes after pulses

for i = 1:length(triggerPulses)
    stimulatePeak = [stimulatePeak; stimulatedPulses(find(stimulatedPulsesLocs > (triggerPulsesLocs(i)+skipWindow),1))]; % value of the first peak after artefact
    stimulatePeakLocs = [stimulatePeakLocs; stimulatedPulsesLocs(find(stimulatedPulsesLocs > (triggerPulsesLocs(i)+skipWindow),1))]; % location of the first spike after artefact
end


end


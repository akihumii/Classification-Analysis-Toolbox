function data = stimulateSquareWave(dataLength, pulsePeriod, pulseDuration, amplitude, intraGap)
%stimulateSquareWave 
% input:    all units are in sample points
% 
%   output = stimulateSquareWave()

data = zeros(dataLength,1); % initiate square wave with zeros

pulseStartingPoint = 1:pulsePeriod:dataLength;
numPulses = length(pulseStartingPoint);

pulse = [-amplitude*ones(pulseDuration,1); zeros(intraGap,1); amplitude*ones(pulseDuration,1)]; % single pulse shape
lengthPulse = length(pulse); % in sample points

for i = 1:numPulses
    data(pulseStartingPoint(i) : pulseStartingPoint(i)+lengthPulse-1, 1) = pulse;
end

end


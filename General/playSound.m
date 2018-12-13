function [] = playSound(sound,freqMult)
%PLAYSOUND Play the sound
% input:    sound:  'gong', 'handel'
%   [] = playSound(sound,freqMult)

load([sound,'.mat'])

soundsc(y,freqMult * Fs);

end


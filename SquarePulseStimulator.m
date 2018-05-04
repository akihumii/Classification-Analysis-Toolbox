%% Lijing Square Pulse Stimulator
% Run mainClassifier to get the data first :)

dataRef = signal.dataAll(:,13); % check the timing of each starting point.

chStartingRef = [16,17,18,19];

%% get starting timing and end timing
clear preLocs chLocs

for i = 1:length(chStartingRef)
    preLocs = find(dataRef == chStartingRef(i));
    preLocsDiff = diff(preLocs);
    chLocs(:,i) = preLocs([true;preLocsDiff~=1]);
end

chStartingPoint = chLocs(1:2:size(chLocs,1),:);
chEndPoint = chLocs(2:2:size(chLocs,1),:);

%%








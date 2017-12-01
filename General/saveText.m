function [] = saveText(accuracy,const,linear,channelPair, threshold, windowSize)
%saveText Summary of this function goes here
%   Detailed explanation goes here

maxLocs = find(accuracy==max(accuracy));
maxLocs = maxLocs(1);
bestChannel = channelPair(maxLocs,:);
bestChannel = bestChannel(~isnan(bestChannel));
minThreshold = min(threshold(:,bestChannel));

% [file, path] = uiputfile('*.txt', 'Save text file at');
path = 'C:\DrAmit\IntanData\Parameters\';
allFiles = dir(path);
numAllFiles = length(allFiles)-2;
textID = num2str(numAllFiles + 1);

file = num2str(['parameters',textID,'.txt']);

fid = fopen([path, file],'w');
fprintf(fid, '%f \r\n', const(maxLocs) , linear(maxLocs), windowSize, minThreshold);
fprintf(fid, '%d \r\n', bestChannel);
fprintf(fid, '\r\n');
fprintf(fid, '%f ', const);
fprintf(fid, '\r\n');
fprintf(fid, '%f ', linear);
fprintf(fid, '\r\n');
fprintf(fid, '%f ', accuracy);
fprintf(fid, '\r\n \r\n');
for i = 1:size(channelPair,1)
    pair = channelPair(i,~isnan(channelPair(i,:)));
    fprintf(fid, '%d ', pair);
    fprintf(fid, '\r\n');
end
fclose(fid);

display(['accuracy = ', num2str(accuracy(maxLocs))])
display(['const = ', num2str(const(maxLocs))])
display(['linear =  ', num2str(linear(maxLocs))])
display(['channel = ', mat2str(bestChannel)])

msg1 = popMsg('', 'Finished.');
pause(1)
delete(msg1)

end


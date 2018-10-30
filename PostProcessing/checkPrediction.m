function output = checkPrediction(data)
%CHECKPREDICTION Change the data into trigerring one only if either both
%the first two are one or both the last two are one. It applies on four
%bits data.
% 
%   output = checkPrediction(data)
output = data;

if all(output(1,1:2))
    output(1,2) = 0;
end

if all(output(1,3:4))
    output(1,4) = 0;
end

% if ~isequal(output,data)
%     disp(['Changed predicted class from ',num2str(bi2de(data,'left-msb')),' to ',num2str(bi2de(output,'left-msb')),'...'])
% end

end


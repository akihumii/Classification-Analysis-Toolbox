function [] = showProgressPercentage(step,totalSteps)
%showProgressPercentage Show the percentage until finish. There shouldsn't
%be other output printing in any other place in this loop.
% 
% input:    step:   current iteration
%           totalSteps: total iteration
% 
%   [] = showProgressPercentage(step,totalSteps)

percentage = 100 * step/totalSteps;

if (rem(round(percentage, 1), 1) == 0)
    reverseStr = '';
    msg = sprintf('\r Percent done: %3d', round(percentage, 1));
    reverseStr = repmat(sprintf('\b'), 1, length(msg));   
    fprintf([reverseStr, msg]);
end

if (percentage >= 100)
    fprintf('\r');
end


end


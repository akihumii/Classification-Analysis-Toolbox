function timeString = time2string()
%time2string Generate a string of characters of current time.
%   timeString = time2string()

currentTime = clock;
timeString = '';
for i = 1:6
    timeElementTemp = num2str(currentTime(i));
    if length(timeElementTemp) < 2
        timeElementTemp = ['0',timeElementTemp];
    end
    timeString = [timeString, timeElementTemp];
end

timeString = timeString(1:end-4); % omit the decimal places



end


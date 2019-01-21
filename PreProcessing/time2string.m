function timeStringFinal = time2string()
%time2string Generate a string of characters of current time.
%   timeString = time2string()

currentTime = clock;

timeStringFinal = join(sprintf('%02.0f',currentTime));

end


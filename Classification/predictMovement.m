function command = predictMovement(features, parameter)
%predictMovement Load the equation parameters and predict the movement by
%running through the LDA equation and observing the sign
%   command = predictMovement(features, parameter)

numFile = length(features); % number of files

command = sign(parameter.const + parameter.linear * ...
    features.maxValue{1,1}{1,1}(parameter.channel,:)); % -1 if smaller than zero, 1 if larger than zero
command(command == -1) = 0; % replace -1 with 0
command = num2str(command');

end


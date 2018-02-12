function output = omitNan(data,dim)
%omitNan Omit either the column or the row of nan values
%
% input:    dim:    1 to delete columns, 2 to delete rows
%
%   output = omitNan(data,dim)

nanLogic = ~isnan(data); % convert to logics if Nan, then 1

checkNan = sum(nanLogic,dim); % check if there's any nan

output = data; % initiate output

if dim == 1
    output(:,checkNan == 0) = [];
elseif dim == 2
    output(checkNan == 0,:) = [];
else
    warning('Nothing has been done in omitNan due to invalid input ''dim''');
end


end


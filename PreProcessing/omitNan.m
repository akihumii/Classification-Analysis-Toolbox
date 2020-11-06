function output = omitNan(data,dim,type)
%omitNan Omit either the column or the row of nan values (can be found in
%static function in Struct as well!)
%
% input:    dim:    1 to delete columns, 2 to delete rows
%           type:   'all' for omitting only the arrays filled with only Nan;
%                   'any' for omitting the arrays filled with even one Nan.
%
%   output = omitNan(data,dim,type)

if ~isempty(data)
    nanLogic = isnan(data); % convert to logics, if Nan, then 1
    
    output = data; % initiate output
    
    if dim == 1
        if isequal(type,'all')
            output(:,all(all(nanLogic,dim),3),:) = [];
        elseif isequal(type,'any')
            output(:,all(any(nanLogic,dim),3),:) = [];
        else
            warning('Invalide input when omitting Nan...')
        end
    elseif dim == 2
        if isequal(type,'all')
            output(all(all(nanLogic,dim),3),:,:) = [];
        elseif isequal(type,'any')
            output(all(any(nanLogic,dim),3),:,:) = [];
        else
            warning('Invalid input when omitting Nan...')
        end
    elseif dim == 3
        if isequal(type,'all')
            output(:,:,all(all(nanLogic,dim),3)) = [];
        elseif isequal(type,'any')
            output(:,:,all(any(nanLogic,dim),3)) = [];
        else
            warning('Invalid input when omitting Nan...')
        end
    else
        warning('Nothing has been done in omitNan due to invalid input ''dim''');
    end
    
    output = squeezeNan(output,dim);
    
    % if dim == 2 && size(output,2) == 1
    %     output = checkSizeNTranspose(output,1);
    % end
else
    output = data;
end
end


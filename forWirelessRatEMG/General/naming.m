function titleName = naming(files, iter)
%naming Summary of this function goes here
%   Detailed explanation goes here

for i = 1:iter
    disp('Loading...')
    titleName{i} = files{i}(1:end-4);
    
    for f = 1:size(titleName{i},2)
        if isequal(titleName{i}(f),'_')
            titleName{i}(f) = ' ';
        end
    end
end

end


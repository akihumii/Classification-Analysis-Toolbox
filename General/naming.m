function titleName = naming(files)
%naming Summary of this function goes here
%   Detailed explanation goes here

disp('Loading...')
titleName = files(1:end-4);

titleName = strrep(titleName,'_',' ');

end


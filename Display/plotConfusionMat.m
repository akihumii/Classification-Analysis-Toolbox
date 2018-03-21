function varargout = plotConfusionMat(predict,real)
%plotConfusionMat Plot the confusion matrix.
% 
% output:   varargout{1,1} = h;
%           varargout{2,1} = f;
%   varargout = plotConfusionMat(predict,real)

isLabels = unique(real);
[n,p] = size(real);

[~,grpOOF] = ismember(predict,isLabels); 
nLabels = numel(isLabels);
oofLabelMat = zeros(nLabels,n); 
idxLinear = sub2ind([nLabels n],grpOOF,(1:n)'); 
oofLabelMat(idxLinear) = 1; % Flags the row corresponding to the class 

[~,grpY] = ismember(real,isLabels); 
YMat = zeros(nLabels,n); 
idxLinearY = sub2ind([nLabels n],grpY,(1:n)'); 
YMat(idxLinearY) = 1; 

figure;
plotconfusion(YMat,oofLabelMat);
h = gca;
f = gcf;
h.XTickLabel = [num2cell(isLabels); {''}];
h.YTickLabel = [num2cell(isLabels); {''}];

if nargout >= 1
    varargout{1,1} = h;
elseif nargout >= 2
    varargout{2,1} = f;
end

end


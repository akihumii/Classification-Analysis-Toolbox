function mat = surroundingMat(array, type)
%SURROUNDINGMAT Create an surrounding mat, the middle element is the
%largest number, and the surrounding elements lie decendingliy arround it
% input: array: an array for plotting
%        type:  1: plot circular 3D figure;
%               2: plot rectangular
% 
%   output = surroundingMat(array, type)

close all

if nargin < 2
    type = 1; % 1 and 2 are squares, 3 is cone
end

switch type
    case 1
        numElement = length(array);
        mat = repmat(checkSizeNTranspose(array,1),numElement,1);
        
        theta = linspace(0,2*pi,numElement);
        r = linspace(0,2*pi,numElement);
        [R,T] = meshgrid(r,theta);
        
        Z_top = mat; %%Create top and bottom halves

        [X,Y,Z] = pol2cart(T,R,Z_top); %%Convert to Cartesian coordinates and plot

        X = X / max(X(:)) * numElement;
        Y = Y / max(Y(:)) * numElement;
        
        surf(X,Y,Z);

        shading interp
        colormap jet
        
        colorbar
        
    case 2
        numElement = length(array);
        
        mat = array(1) * ones(numElement*2-1);
        for i = 2:numElement
            mat(i:end-i+1 , i:end-i+1) = array(i);
        end
        
    otherwise
                mat = ones(array);     
        for i = 2:array
            mat(i:end,i:end) = i*ones(array-i+1);
        end
        mat = [mat , fliplr(mat)];
        mat(:,array) = [];
        mat = [mat ; flipud(mat)];
        mat(array,:) = [];

end

end

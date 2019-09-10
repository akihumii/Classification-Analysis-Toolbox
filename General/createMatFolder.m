function [] = createMatFolder(m)
%CREATEFOLDER Create folder with csv file inside
%   Detailed explanation goes here
% createMatFoldersRecursive(m, m(:,1), 1, 1);

for a = m(1,1): 2: m(1,2)
    for b = m(2,1): 2: m(2,2)
        for c = m(3,1): 2: m(3,2)
            for d = m(4,1): 2: m(4,2)
                for e = m(5,1): 2: m(5,2)
                    for f = m(6,1): 2: m(6,2)
                        for g = m(7,1): 2: m(7,2)
                            for h = m(8,1): 2: m(8,2)
                                for i = m(9,1): 2: m(9,2)
                                    for j = m(10,1): 2: m(10,2)
                                        for k = m(11,1): 2: m(11,2)
                                            for l = m(12,1): 2: m(12,2)
                                                matrix = [a,b,c,d,e,f,g,h,i,j,k,l];
                                                disp(matrix)
                                                filename = strrep(int2str(matrix),' ','');
                                                mkdir(filename);
                                                dlmwrite(fullfile(filename,'parameters.csv'), matrix);
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end
end

function createMatFoldersRecursive(boundary, currentIndexMat, currentIndexMajor, currentIndexMinor)
if currentIndexMajor <= size(boundary, 1)
    if currentIndexMinor < currentIndexMajor - 1 ||...
            currentIndexMat(currentIndexMinor) ~= boundary(currentIndexMinor, 2)
        checkMats(boundary, currentIndexMat, currentIndexMajor, currentIndexMinor);
        if currentIndexMat(currentIndexMinor) ~= boundary(currentIndexMinor,2)
            currentIndexMat(currentIndexMinor) = currentIndexMat(currentIndexMinor) + 1;
        else
            currentIndexMinor = currentIndexMinor + 1;
%             currentIndexMat(currentIndexMinor) = currentIndexMat(currentIndexMinor) + 1;
        end
        createMatFoldersRecursive(boundary, currentIndexMat, currentIndexMajor, currentIndexMinor)
        
    elseif currentIndexMajor <= length(boundary) &&...
            currentIndexMat(currentIndexMajor) <= boundary(currentIndexMajor,2)
        checkMats(boundary, currentIndexMat, currentIndexMajor, currentIndexMinor);
        if currentIndexMat(currentIndexMinor) ~= boundary(currentIndexMinor,2)
            currentIndexMat(currentIndexMinor) = currentIndexMat(currentIndexMinor) + 1;
        elseif currentIndexMat(currentIndexMajor) ~= boundary(currentIndexMajor, 2)
            currentIndexMat(currentIndexMajor) = currentIndexMat(currentIndexMajor) + 1;
            currentIndexMinor = 1;
            currentIndexMat(1:currentIndexMajor - 1) = boundary(1:currentIndexMajor - 1, 1);
        else
            currentIndexMajor = currentIndexMajor+1;
            currentIndexMinor = 1;
            currentIndexMat(1:currentIndexMajor - 1) = boundary(1:currentIndexMajor - 1, 1);
            
            if currentIndexMajor <= size(boundary, 1)
                currentIndexMat(currentIndexMajor) = currentIndexMat(currentIndexMajor) + 1;
            end
        end
        createMatFoldersRecursive(boundary, currentIndexMat, currentIndexMajor, currentIndexMinor)
    end
end
end

function checkMats(boundary, currentIndexMat, currentIndexMain, currentIndexMinor)
fprintf('\nmat: %d, %d, %d, %d, indexMain: %d, indexMinor: %d\n', currentIndexMat', currentIndexMain', currentIndexMinor')
end
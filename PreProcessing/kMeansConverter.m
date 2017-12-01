function output = kMeansConverter(data, k)
%kMeanClassify Generate k-means clustering from input data
%   output = kMeansConverter(data, k)

[idx,Centroid,sumDistanceWithinClass,Distance] = kmeans(data, k);

for i = 1:k
    numPointsWithinClass(i,1) = length(find(idx==i));
    meanDistanceWithinClass(i,1) = sumDistanceWithinClass(i,1) / numPointsWithinClass(i,1);
end

output.idx = idx; % class of observation
output.Centroid = Centroid; % coordinates of centroid
output.sumDistanceWithinClass = sumDistanceWithinClass; % sum of distance within one class (k-by-1)
output.Distance = Distance; % distance of each point to every centroid (n-by-k)
output.meanDistanceWithinClass = meanDistanceWithinClass; % mean of distance within one class (k-by-1)

end


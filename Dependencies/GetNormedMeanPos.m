function [meanPos_N, meanPos] = GetNormedMeanPos(pixelList, height, width)
% FUNCTION: compute position coordinate of superpixels

spNum = length(pixelList);
meanPos_N = zeros(spNum, 2);
meanPos = zeros(spNum, 2);

for n = 1 : spNum
    [rows, cols] = ind2sub([height, width], pixelList{n});    
    meanPos_N(n,1) = mean(rows) / height;
    meanPos(n,1) = mean(rows);
    meanPos_N(n,2) = mean(cols) / width;
    meanPos(n,2) = mean(cols);
end
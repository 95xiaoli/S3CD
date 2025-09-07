function meanCol = GetMeanColor(image, pixelList)
% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014
% image 三通道影像
% pixelList 差像素里面的像素的索引列表

[h, w, chn] = size(image);
tmpImg=reshape(image, h*w, chn);

spNum = length(pixelList);
meanCol=zeros(spNum, chn);
for i=1:spNum
    meanCol(i, :)=mean(tmpImg(pixelList{i},:), 1);
end
if chn ==1 %for gray images
    meanCol = repmat(meanCol, [1, 3]);
end
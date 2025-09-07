function [idxImg, adjcMatrix, pixelList, seg_im, l_r_diff, t_b_diff, edge_pixel_list] = SLIC_Split(noFrameImg, spnumber_input)
% Segment rgb image into super-pixels using SLIC algorithm:

% R.Achanta, A.Shaji, K.Smith, A.Lucchi, P.Fua, and S.Susstrunk. Slic 
% superpixels compared to state-of-the-art superpixel methods. IEEE
% Transactions on Pattern Analysis and Machine Intelligence, 2012.

% Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

% Input: 
%   noFrameImg ------ image to segment
%   spnumber_input ------ approaximate number of output superpixels
% Output: 
%   idxImg ------ indexed image after segmentation
%   adjcMatrix ------ adjacent matrix of super-pixels

%% Segment using SLIC:
% compactness = 20; %the larger, the more regular patches will get
% [idxImg, spNum] = SLIC_mex(noFrameImg, spnumber_input, compactness);
[idxImg, spNum] = superpixels(noFrameImg,spnumber_input); 
figure;
BW = boundarymask(idxImg);
imshow(imoverlay(noFrameImg,BW,'cyan'),'InitialMagnification',100);
title('分割的结果');

%%
[adjcMatrix, seg_im, l_r_diff, t_b_diff, edge_pixel_list] = GetAdjMatrix(idxImg, spNum);

%%
pixelList = cell(spNum, 1);
for n = 1:spNum
    pixelList{n} = find(idxImg == n);
end

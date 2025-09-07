function [adjMatrix, seg_im, leftrightDiff, topbotDiff, edge_pixel_list] = GetAdjMatrix(idxImg, spNum)
% Get adjacent matrix of super-pixels
% idxImg is an integer image, values in [1..spNum]

% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014

[h, w] = size(idxImg);

%Get edge pixel locations (4-neighbor)
topbotDiff = diff(idxImg, 1, 1) ~= 0;
topEdgeIdx = find( padarray(topbotDiff, [1 0], false, 'post') ); %those pixels on the top of an edge
botEdgeIdx = topEdgeIdx + 1;

leftrightDiff = diff(idxImg, 1, 2) ~= 0;
leftEdgeIdx = find( padarray(leftrightDiff, [0 1], false, 'post') ); %those pixels on the left of an edge
rightEdgeIdx = leftEdgeIdx + h; % due to the column-first storage strategy

%Get image segmentation
% l_r = imPad(double(leftrightDiff),[0,0,0,1],'symmetric');
% t_b = imPad(double(topbotDiff),[0,1,0,0],'symmetric');
l_r = padarray(leftrightDiff, [0 1], false, 'post');
t_b = padarray(topbotDiff, [1 0], false, 'post');
seg_im = logical(l_r)+logical(t_b);
seg_im = logical(seg_im);

%Get adjacent matrix of super-pixels
adjMatrix = zeros(spNum, spNum);
adjMatrix( sub2ind([spNum, spNum], idxImg(topEdgeIdx), idxImg(botEdgeIdx)) ) = 1;
adjMatrix( sub2ind([spNum, spNum], idxImg(leftEdgeIdx), idxImg(rightEdgeIdx)) ) = 1;
adjMatrix = adjMatrix + adjMatrix';
adjMatrix(1:spNum+1:end) = 1;%set diagonal elements to 1
adjMatrix = sparse(adjMatrix);

%Get edge pixels of each super-pixel
edge_left = zeros(h, w);
edge_right = zeros(h, w);
edge_top = zeros(h, w);
edge_bot = zeros(h, w);

edge_left(sub2ind([h, w], leftEdgeIdx)) = idxImg(leftEdgeIdx);
% edge_left2(sub2ind([h, w], rightEdgeIdx)) = idxImg(leftEdgeIdx);
edge_right(sub2ind([h, w], leftEdgeIdx)) = idxImg(rightEdgeIdx);
% edge_right2(sub2ind([h, w], rightEdgeIdx)) = idxImg(rightEdgeIdx);
edge_top(sub2ind([h, w], topEdgeIdx)) = idxImg(topEdgeIdx);
% edge_top2(sub2ind([h, w], botEdgeIdx)) = idxImg(topEdgeIdx);
edge_bot(sub2ind([h, w], topEdgeIdx)) = idxImg(botEdgeIdx);
% edge_bot2(sub2ind([h, w], botEdgeIdx)) = idxImg(botEdgeIdx);

edge_pixel_list = cell(spNum,1);
% aa = zeros(h,w);
for i = 1:spNum
    temp1 = union(find(edge_left==i), find(edge_right==i));
    temp2 = union(find(edge_top==i), find(edge_bot==i));
%     temp3 = union(find(edge_left2==i), find(edge_right2==i));
%     temp4 = union(find(edge_top2==i), find(edge_bot2==i));
%     edge_pixel_list{i} = union(union(temp1, temp2), union(temp3, temp4));
    edge_pixel_list{i} = union(temp1, temp2);

%     aa(sub2ind([h, w],edge_pixel_list{i})) = 1;
end

end
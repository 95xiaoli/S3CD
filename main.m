%%   main code for S3CD model

clear;clc;close all;

%% prepare data
im_path = './data/';
gt_path = './GT/';
im_suffix = '.jpg';
gt_suffix = '.png';
imgs_list = dir(strcat(im_path,'*',im_suffix));
sample_num = length(imgs_list);

% prepare deep feature
% feat_path = './deepfeature/';
% feat_suffix = '.mat'
% feat_list = dir(strcat(feat_path,'*',feat_suffix));


%% main
i=1;
fprintf('Processing %d image...\n',i);
im_name = imgs_list(i).name;
im_idx = im_name(1:strfind(im_name,'.')-1);
img.RGB = imread(strcat(im_path,im_name));
% img.RGB = cat(3, img.RGB, img.RGB,img.RGB);  


gt_name = strcat(im_idx,gt_suffix);
gt_im = imread(strcat(gt_path,gt_name));
[height,width,d] = size(gt_im);

%% get feature matrtix

%input deep feature
j=1;
fprintf('Processing %d image...\n',j);

% tic;
[view, pixelList, sup, adjc_mat, seg_im, fstReachMat, bgPrior, bdCon,W] = GenChaFeatMat(img);
[len,dim] = size(view); 
view1 = view(:,1)';
view2 = view(:,2:13)';
view3 = view(:,14:49)';
% view4 = view(:,50:113)';
% view5 = view(:,114:end)';
% toc;
X_feature = cat(1, view1, view2, view3);

%%  低秩矩阵分解计算


%load data
Data = {view1,view2,view3};  %,view2,view3 ,view4  ,view5
F = view(:,1:49);

tic;
 [Z, E] = S3CD(Data);  
toc;


%% postprocessing

result1 = zeros(1,len);

for i = 1:length(Z)
        result1 = result1 + sum(abs(Z{i}), 1);
end


Res = mapminmax(result1,0,1);


intial_result = zeros(height,width);
for i=1:length(pixelList)
    intial_result(pixelList{i}) = Res(i);
end
figure;imshow(intial_result);


% close all;

%%  Fusion
lambda = 0.5;
Z_fuse = lambda * (mapminmax(Res,0,1)') + (1-lambda) * (mapminmax(bgPrior',0,1)');

intial_result2 = zeros(height,width);
for i=1:length(pixelList)
    intial_result2(pixelList{i}) = Z_fuse(i);
end
figure;imshow(intial_result2);

%%  Classification refinement
%分类细化模块是可选项，当结果差时可直接做二值化聚类

cc=Z_fuse'; 
% threshold strategy
mean_th = 2;   
min_th=0.5;

pos_index = find(cc>mean_th*mean(cc));   
neg_index = find(cc<min_th*mean(cc));
known_index = [pos_index, neg_index];

unk_index = setdiff(1:length(cc), known_index); 
pixel_amount = sup.pixNum;   




% sample selection
tic;
idx_n = cc<min_th*mean(cc);
im_sample_n = F(idx_n,:);   
% idx_p = S_l1>mean_th*mean(S_l1);
idx_p = cc>mean_th*mean(cc);
im_sample_p = F(idx_p,:);   
num_p = length(find(idx_p>0));
num_n = length(find(idx_n>0));    

im_sample_k = vertcat(im_sample_n,im_sample_p);
im_label_k = zeros(num_n+num_p,2);
im_label_k(1:num_n,2) = 1;
im_label_k(num_n+1:end,1) = 1;   

im_idx_k = union(find(idx_n>0), find(idx_p>0));   
im_idx_unk = setdiff(1:length(result1), im_idx_k);   
im_sample_unk = F(im_idx_unk,:);           
im_label_unk = zeros(length(im_idx_unk),2);       
im_label_unk(:,1) = cc(im_idx_unk);
im_label_unk(:,2) = 1-im_label_unk(:,1);         

% 构建正负样本的邻接矩阵
selected_adj_mat = adjc_mat(im_idx_k, im_idx_k);

% weights = zeros(1,num_n+num_p);
weights = zeros(1,length(pixelList));
weights(1:num_n) = 1;
weights(num_n+1:num_n+num_p) = num_n/num_p;
weights(num_n+num_p+1:end) = 0.5;

% 训练样本
train_x = [im_sample_k; im_sample_unk];
train_y = [im_label_k; im_label_unk];
train_x = mapminmax(train_x,0,1);
%  train_x = [im_sample_k];
% train_y = [im_label_k];
% train_x = mapminmax(train_x,0,1);
% pre_x = [im_sample_unk];


% 参数设置
eta_1 = 0.01;    
sigma_kernel = 1; 
eta_2 = 1000;       

tic;
pred = fine_proc_krr_laplacian(train_x, train_y, weights, eta_1, adjc_mat, sigma_kernel, eta_2);
toc;

final_labels = -ones(length(pixelList), 1);
final_labels(neg_index) = 0; %1;
final_labels(pos_index) = 1; %0;
final_labels(unk_index) = 2-pred(num_n+num_p+1:end);


% Binary change maps
dd = final_labels*255;

final_slience1 = zeros(height,width);
for i=1:length(pixelList)
    final_slience1(pixelList{i}) = dd(i);
end
figure;imshow(final_slience1); 



































































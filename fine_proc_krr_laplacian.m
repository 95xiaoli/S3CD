function predicted_labels = fine_proc_krr_laplacian2(A, Y, weights, eta, adj_mat, sigma_kernel, theta)
% CR模块函数：
% 输入：
%   A: 训练样本特征矩阵 [n_samples, n_features]
%   Y: 标签矩阵 [n_samples, n_classes]
%   weights: 样本权重向量 [1, n_samples]
%   eta: 回归正则化系数
%   adj_mat: 超像素邻接矩阵 [n_samples, n_samples]
%   sigma_kernel: RBF核参数
%   theta: 图拉普拉斯正则化系数

% --------------------- 0. 权重矩阵构造 ---------------------
weight_mat = diag(weights); % 转换为对角矩阵 [n_samples, n_samples]

% --------------------- 1. 核矩阵计算 ---------------------
A_norm = sum(A.^2, 2);
K = exp(-(A_norm + A_norm' - 2*(A*A'))) / (2*sigma_kernel^2); % [n_samples, n_samples]

% --------------------- 2. 图拉普拉斯矩阵 ---------------------
D = diag(sum(adj_mat, 2));     % 度矩阵
L = D - adj_mat;               % 拉普拉斯矩阵

% --------------------- 3. 目标函数 ---------------------
% n_samples = size(K, 1);
% I = eye(n_samples);
% regularization_term = lambda1*I + beta*K*L*K;

n_train = size(K, 1);
combined_matrix = K + eta*eye(n_train) + theta*L*K;

% 加权最小二乘解
% W = (K + regularization_term) \ (weight_mat * Y); % [n_samples, n_classes]
W = combined_matrix \ (weight_mat * Y); % [n_samples, n_classes]

% --------------------- 4. 预测 ---------------------
pred = K * W; 



pred_test_prob = exp(pred) ./ sum(exp(pred), 2);
% 方法1: 直接取最大响应值对应的类别
[~, predicted_labels] = max(pred_test_prob, [], 2);
% predicted_labels为50×1向量，1=变化类，2=不变类
end
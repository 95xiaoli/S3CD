function [bgPrior, bdCon] = GetPriorByRobustBackgroundDetection(distMat, fstReachMat, bndIdx)
    % link boundary superpixels
    fstReachMat(bndIdx, bndIdx) = 1;
    fstReachMat = tril(fstReachMat, -1);
    distMatEdge = distMat(fstReachMat>0);
    % Cal pair-wise shortest path cost (geodesic distance)
    % geoDistMat = graphallshortestpaths(sparse(fstReachMat), 'directed', false, 'Weights', distMatEdge);
    % geoDistMat = shortestpath(sparse(fstReachMat), 'directed', false, 'Weights', distMatEdge);
    % G = graph(sparse(fstReachMat), 'Weights', distMatEdge(:));
    % G = graph(sparse(fstReachMat)(:,1), sparse(fstReachMat)(:,2), [], 'Weights', distMatEdge(:)); % 无向图
    % G = graph(find(sparse(fstReachMat), 1), find(sparse(fstReachMat), 2), [], 'Weights', distMatEdge(:));
    
    % adjMatrixSparse = sparse(fstReachMat);
    

    n = size(fstReachMat, 1);

    
    [row, col, val] = find(fstReachMat);

    
    assert(length(distMatEdge) == nnz(fstReachMat), '权重数组的长度与非零边的数量不匹配');

   
    % 创建边列表矩阵
    edgeList = [row, col];

    % 创建权重向量（确保它是列向量）
    weights = distMatEdge(:); 

    % 创建无向图对象，并设置权重
    G = graph(edgeList(:, 1), edgeList(:, 2), weights);
    % 计算所有节点对之间的最短路径
    geoDistMat = distances(G);
    

  
    
    
    
    % G = graph(find(adjMatrixSparse), find(adjMatrixSparse'), distMatEdge(~isnan(distMatEdge)));  
    % G = graph(adjMatrixSparse);
    
    % geoDistMat = distances(G);
    % geoDistMat = distances(sparse(fstReachMat), 'directed', false, 'Weights', distMatEdge);
    geoDistMat = reshape(mapminmax(geoDistMat(:)',0,1), size(geoDistMat)); 
    Wgeo = Dist2WeightMatrix(geoDistMat, 0.12);  %0.12
    Len_bnd = sum( Wgeo(:, bndIdx), 2); % length of perimeters on boundary
    Area = sum(Wgeo, 2);    % soft area
    bdCon = Len_bnd ./ sqrt(Area);
    bdCon = mapminmax(bdCon',0,1)';
    bgPrior = exp(-bdCon.^2 / (2 * 0.3 * 0.3)); %Estimate bg probability  0.3
    
end
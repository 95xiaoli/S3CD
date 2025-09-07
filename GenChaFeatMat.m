function [featMat, pixelList, sup, adjc_mat, seg_im, fstReachMat, bgPrior, bdCon, W] = GenChaFeatMat(img) 
    [img.height, img.width] = size(img.RGB(:,:,1));

    %% STEP-1. Generate superpixels using SLIC
    % [sup.label, sup.num, sup.Lab] = PerformSLIC(noFrameImg);
  
    [sup.label, adjc_mat, pixelList, seg_im] = SLIC_Split(img.RGB, 800);  % !!! 800 is superpixel numbers 
    
%     [sup.label, adjc_mat, pixelList] = SLIC_Split(noFrameImg.RGB, 200);
    sup.num = length(pixelList);
    meanRgbCol = GetMeanColor(img.RGB, pixelList);  
    meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
    sup.Lab = meanLabCol;
    sup.Rgb = meanRgbCol;

     % get the indexes of boundary superpixels
    bndIdx = GetBndSupIdx(sup.label);
    
    % get superpixel statistics
    sup.pixIdx = pixelList;
    sup.pixNum = zeros(sup.num,1);
    for j = 1:sup.num
         temp = find(sup.label==j);
         sup.pixNum(j) = length(temp);  
    end
[sup.pos_N, sup.pos] = GetNormedMeanPos(sup.pixIdx, img.height, img.width);
    %% STEP-2. Extract features
      [featureimg] = Extract_Feature(img);

    for j = 1:1
        featureimg(:,:,j) = mat2gray(featureimg(:,:,j)).*255;
    end
    featMat = GetMeanFeat(featureimg, sup.pixIdx);  

    featMat = featMat./255;
    colorFeatures = featMat(:,1:1);
    medianR = median(colorFeatures(:,1)); %medianG = median(colorFeatures(:,2)); medianB = median(colorFeatures(:,3));
    featMat(:,1:1) = (featMat(:,1:1)-1.2*repmat(medianR,size(featMat,1),1))*1.5;  


       %% STEP-4. Create index tree
    % get the first and second order reachable matrix (a.k.a adjacent matrix)
    [fstReachMat, fstSndReachMat, ~] = GetFstSndReachMat(sup.label, sup.num);
    % compute color distance between adjacent superpixels
    colorDistMat = ComputeFeatDistMat(sup.Lab);
    %% STEP-5. Get high-level priors
    if ~exist('colorPriorMat','var')
        fileID = fopen('ColorPrior','rb');
        data = fread(fileID,'double');
        fclose(fileID);
        colorPriorMat = reshape(data(end-399:end), 20, 20);
    end
    % get banckground prior by robust background detection [W. Zhu et al., CVPR'14]
    [bgPrior, bdCon] = GetPriorByRobustBackgroundDetection(colorDistMat, fstReachMat, bndIdx);
   

     %% STEP-6. Compute affinity and laplacian matrix
    % link boundary superpixels
    fstSndReachMat(bndIdx, bndIdx) = 1;
    fstSndReachMat_lowTri_Bnd = tril(fstSndReachMat, -1);
    [tmpRow, tmpCol] = find(fstSndReachMat_lowTri_Bnd>0);
    edge = [tmpRow, tmpCol];
    % get the weights on edges
    weightOnEdge = ComputeWeightOnEdge(colorDistMat, fstSndReachMat_lowTri_Bnd, 0.05);
    % compute affinity matrix
    W = sparse([edge(:,1);edge(:,2)], [edge(:,2);edge(:,1)], [weightOnEdge; weightOnEdge], sup.num, sup.num);
    DCol = full(sum(W,2));
    D = spdiags(DCol,0,speye(sup.num));
    M = D - W;
end
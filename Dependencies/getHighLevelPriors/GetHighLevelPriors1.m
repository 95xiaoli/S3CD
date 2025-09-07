function prior = GetHighLevelPriors(supPos, supNum, colorPriorMat, colorFeatures, bgPrior, sup_label)
% center prior
%     center = [0.5 0.5];
center1 = [0.3169 0.1459];
centerPrior1 = zeros(supNum,1);
sigma = 0.1;
for c = 1:supNum
    tmpDist1 = norm( supPos(c,:) - center1 );
    centerPrior1(c) = exp(-tmpDist1^2/(2*sigma^2));
end

center2 = [0.8308 0.2401];
centerPrior2 = zeros(supNum,1);
for c = 1:supNum
    tmpDist2 = norm( supPos(c,:) - center2 );
    centerPrior2(c) = exp(-tmpDist2^2/(2*sigma^2));
end

center3 = [0.2185 0.3343];
centerPrior3 = zeros(supNum,1);
for c = 1:supNum
    tmpDist3 = norm( supPos(c,:) - center3 );
    centerPrior3(c) = exp(-tmpDist3^2/(2*sigma^2));
end

center4 = [0.5754 0.7964];
centerPrior4 = zeros(supNum,1);
for c = 1:supNum
    tmpDist4 = norm( supPos(c,:) - center4 );
    centerPrior4(c) = exp(-tmpDist4^2/(2*sigma^2));
end
centerPrior = centerPrior1 + centerPrior2 + centerPrior3 + centerPrior4;
centerPrior=centerPrior./max(centerPrior(:));
figure;featMapShow(centerPrior, sup_label);title('位置显著性');
%【0.3169，0.1459】【0.8308，0.2401】[0.2185 0.3343][0.5754 0.7964]


% color prior
colorPrior = zeros(supNum,1);
for index = 1:supNum
    nR = colorFeatures(index,1)/(sum(colorFeatures(index,:))+1e-6);
    nG = colorFeatures(index,2)/(sum(colorFeatures(index,:))+1e-6);
    x = min(floor(nR/0.05)+1,20);
    y = min(floor(nG/0.05)+1,20);
    colorPrior(index,1) = (colorPriorMat(x,y)+0.5)/1.5;
end
% integrate center, color and background priors
prior = bgPrior;   %.* colorPrior  centerPrior.* 
prior = mapminmax(prior',0,1)';
figure;featMapShow(prior, sup_label);title('位置加背景显著性');
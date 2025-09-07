function [featureimg] = Extract_Feature(img)

process_img = im2single(img.RGB);
[height,width,~] = size(process_img);

view1 = 1; view2 = 12; view3 = 36; view4 = 576;
featureimg1 = zeros(height,width,view1);
featureimg2 = zeros(height,width,view2);
featureimg3 = zeros(height,width,view3);
featureimg4 = zeros(height,width,view4);

process_img = process_img.*255;




%% Color   
img1 = double(process_img);
featureimg1(:,:,:) = img1(:,:,1);

%% Steerable Pyramid
pos = 1;
grayimg = double(rgb2gray(uint8(process_img)));
[pyr,pind] = buildSpyr(grayimg,3,'sp3Filters');
pyramids = getSpyr(pyr,pind);
pyrNum = size(pyramids,2);
for n = 1:pyrNum-1
    pyrImg = imresize(pyramids{n},[height, width], 'bicubic');
    for i = 1:height
        for j = 1:width   
            featureimg2(i,j,pos) = pyrImg(i,j);
        end
    end
    pos = pos+1;
end
%% gabor filter
pos = 1;
scales = 3;
directions = 12;
[EO, ~] = gaborconvolve(grayimg, scales, directions, 6,2,0.65);

for wvlength = 1:scales
    for angle = 1:directions
        Aim = abs(EO{wvlength,angle});
        maxres = max(Aim(:));
        for i = 1:height
            for j = 1:width
                featureimg3(i,j,pos) = Aim(i,j)/maxres*255;
            end
        end
        pos = pos+1;
    end
end

%%  Deep feature

% featureimg = cat(3, featureimg1, featureimg2, featureimg3, featureimg4);
featureimg = cat(3, featureimg1, featureimg2, featureimg3);

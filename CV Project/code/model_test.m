%% extract feature and test for pos test data
tic
nFeatures=5000;
source = '../INRIAPerson/test_64x128_H96/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

h = 128;
w = 64;
padding = 3;

ICF_test_pos = zeros(l,nFeatures);
for i=1:l
    i
    image = (imread([source, all_imagenames{i}]));
    image=image(padding+1:h+padding, padding+1:w+padding, :);
    
    ICF_test_pos(i, :) = integral_features(image, feature_selection);
end

% ypredict = zeros(1,l);
% for i=1:l
%     i
%     ypredict(i) = predict(ens2,ICF_test_pos(i,:));
% end

ypredict = predict(ens5,ICF_test_pos);
sum(ypredict)/length(ypredict) % 0.9920% for 1126 sample
toc

% Elapsed time is 60.220069 seconds.



%% Extrac featuers and test on randomly sampled negative data
tic
source = '../INRIAPerson/test_64x128_H96/neg/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

ICF_test_neg = zeros(10,nFeatures);
for i=1:l
    i
    image = (imread([source, all_imagenames{i}]));
    image=image(30:30+h-1, 100:100+w-1, :);
    
    ICF_test_neg(i, :) = integral_features(image, feature_selection);
end

ypredict = zeros(1,l);
for i=1:l
    i
    ypredict(i) = predict(ens2,ICF_test_neg(i,:));
end

sum(ypredict==0)/length(ypredict) % 99% on 300 samples
toc

% Elapsed time is 55.730794 seconds.


%% Do sliding window detection on positive images
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

tic
% read one test image with people
image = (imread([source, all_imagenames{1}]));
% im = image(140:477, 138:320, :);
im = image;
figure; imshow(im);
% do sliding window
topLeftRow = 1;
topLeftCol = 1;
[bottomRightCol bottomRightRow d] = size(im);
h = 128;
w = 64;
fcount = 1;
step_size = 6;
score_thr = 1.5; % for select the best sub-window

pos_windows = zeros(10000,5);
num_pos_windows = 0;
% this for loop scan the entire image and extract features for each sliding window
for y = topLeftCol:step_size:bottomRightCol-h
    for x = topLeftRow:step_size:bottomRightRow-w
        window = im(y:y+h-1, x:x+w-1, :);     
        ICF_test = integral_features(window, feature_selection);
        [predict_class, score] = predict(ens2,ICF_test);
        if (predict_class == 1)
            num_pos_windows = num_pos_windows + 1;
            pos_windows(num_pos_windows,:) = [x, y, x+w-1, y+h-1, score(2)];
        end
        
        fcount = fcount+1
    end
end

% select only windows with score > threshold
pos_windows = pos_windows(1:num_pos_windows, :);
selected_pos_windows = pos_windows(pos_windows(:,5)> score_thr, :);
figure; 
subplot(2,2,1);showboxes(im,  pos_windows);
subplot(2,2,2); showboxes(im,  selected_pos_windows);

% My nms function
bestBBox = nms(selected_pos_windows,100,10);
subplot(2,2,3); showboxes(im,  bestBBox);

% nms function by PDollar
bbs = bbNms( selected_pos_windows);
subplot(2,2,4); showboxes(im, bbs);

toc

% Elapsed time is 120.883353 seconds. With new Ghist, part of image
% Elapsed time is 126.511323 seconds. With old Ghist, part of image

% Elapsed time is 2358.794851 seconds. With new Ghist, whole image





%% Fast: Do sliding window detection on positive images
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

tic
% read one test image with people
image = (imread([source, all_imagenames{5}]));
% im = image(140:477, 138:320, :);
im = image;
figure; imshow(im);
% do sliding window
topLeftRow = 1;
topLeftCol = 1;
[bottomRightCol bottomRightRow d] = size(im);
h = 128;
w = 64;
fcount = 1;
step_size = 6;

num_windows = ceil((bottomRightCol-h)/step_size * (bottomRightRow-w)/step_size*1.1);
pos_windows = zeros(num_windows,5);
ICF_test = zeros(num_windows,nFeatures);
windows = zeros(num_windows, 5); % [x1, y1, x2, y2, score]
num_pos_windows = 0;

% this for loop scan the entire image and extract features for each sliding window
for y = topLeftCol:step_size:bottomRightCol-h
    for x = topLeftRow:step_size:bottomRightRow-w
        window = im(y:y+h-1, x:x+w-1, :);     
        ICF_test(fcount, :) = integral_features(window, feature_selection);
        windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
%         [predict_class, score] = predict(ens2,ICF_test);
        fcount = fcount+1
    end
end

ICF_test = ICF_test(1:fcount, :);
[predict_class, scores] = predict(ens2,ICF_test);
pos_windows = windows( predict_class==1, :);
pos_scores = scores(predict_class==1, 2);
pos_windows(:,5) = pos_scores;
 

% select only windows with score > threshold
score_thr = 2.2; % for select the best sub-window
selected_pos_windows = pos_windows(pos_windows(:,5)> score_thr, :);
figure; 
subplot(2,2,1);showboxes(im,  pos_windows);
subplot(2,2,2); showboxes(im,  selected_pos_windows);

% My nms function
bestBBox = nms(selected_pos_windows,100,10);
subplot(2,2,3); showboxes(im,  bestBBox);

% nms function by PDollar
bbs = bbNms( selected_pos_windows);
subplot(2,2,4); showboxes(im, bbs);

toc

% Elapsed time is 38.639265 seconds. Part of the image
% Elapsed time is 720.075299 seconds. Whole image (12min)

% Elapsed time is 1054.289321 seconds. Whole iamge 17434 subwindow (18 min)






%% Do sliding window detection on positive images with pyramid
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

tic
% read one test image with people
image = (imread([source, all_imagenames{5}]));
% im = image(140:677, 238:520, :);
im = image;
figure; imshow(im);

% Build gaussPyramid
num_scale = 3;
gaussPyramid = vision.Pyramid('PyramidLevel', 1);
pyramids = cell(1, num_scale);

pyramids{1} = im2single(im);
for i = 2:num_scale
    pyramids{i} = step(gaussPyramid, pyramids{i-1});
end
% for i = 1:num_scale
%     figure;
%     imshow(im_pyramid{i});
%     size(im_pyramid{i})
% end


% do sliding window
topLeftRow = 1;
topLeftCol = 1;
h = 128;
w = 64;
step_size = 6;


all_pos_windows = zeros(50000, 5);
num_pos_windows = 1;
for i = 1:num_scale
    im = pyramids{i};
    [bottomRightCol bottomRightRow d] = size(im);

    num_windows = ceil((bottomRightCol-h)/step_size * (bottomRightRow-w)/step_size*1.1);
    pos_windows = zeros(num_windows,5);
    ICF_test = zeros(num_windows,nFeatures);
    windows = zeros(num_windows, 5); % [x1, y1, x2, y2, score]
    fcount = 1;
    
    % this for loop scan the entire image and extract features for each sliding window
    for y = topLeftCol:step_size:bottomRightCol-h-step_size
        for x = topLeftRow:step_size:bottomRightRow-w-step_size
            window = im(y:y+h-1, x:x+w-1, :);     
            ICF_test(fcount, :) = integral_features(window, feature_selection);    
            windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
            fcount = fcount+1
        end
    end

    ICF_test = ICF_test(1:fcount, :);
    [predict_class, scores] = predict(ens3,ICF_test);
    pos_windows = windows( predict_class==1, :);
    pos_windows = ceil(pos_windows .* 2^(i-1)); % rescale back to origial image coordinates
    
    pos_scores = scores(predict_class==1, 2);
    pos_windows(:,5) = pos_scores;
      
    n_pos_windows_current_im = size(pos_windows);
    all_pos_windows(num_pos_windows:num_pos_windows+n_pos_windows_current_im-1, :) = pos_windows;
    num_pos_windows = num_pos_windows + n_pos_windows_current_im - 1;
    
end

% select only windows with score > threshold
score_thr = 2.5; % for select the best sub-window
selected_pos_windows = all_pos_windows(all_pos_windows(:,5)> score_thr, :);
figure; 
subplot(2,2,1);showboxes(pyramids{1},  all_pos_windows);
subplot(2,2,2); showboxes(pyramids{1},  selected_pos_windows);

% My nms function
bestBBox = nms(selected_pos_windows,50,10);
subplot(2,2,3); showboxes(pyramids{1},  bestBBox);

% nms function by PDollar
bbs = bbNms(selected_pos_windows);
subplot(2,2,4); showboxes(pyramids{1}, bbs);

toc

% Elapsed time is 153.283103 seconds. For 3 scales, part of iamge#5 (140:677, 238:520, :);
% Elapsed time is 1128.880966 seconds. For whole image#5 (19min)
 











%% [[Fast]] Do sliding window detection on positive images with pyramid
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

tic
% read one test image with people
image = (imread([source, all_imagenames{25}]));
% im = image(140:677, 238:520, :);
im = image;
figure; imshow(im);

% Build gaussPyramid
num_scale = 3;
gaussPyramid = vision.Pyramid('PyramidLevel', 1);
pyramids = cell(1, num_scale);
features_pyramid = cell(1, num_scale); 

pyramids{1} = im2single(im);
features_pyramid{1} = gen_feature_channels(im); % ~5.5sec
for i = 2:num_scale
    pyramids{i} = step(gaussPyramid, pyramids{i-1});
    features_pyramid{i} = gen_feature_channels(pyramids{i});
end

% Up to here, ~8sec for one full image, 3 scale levels

% for i = 1:num_scale
%     figure;
%     imshow(im_pyramid{i});
%     size(im_pyramid{i})
% end

% do sliding window
topLeftRow = 1;
topLeftCol = 1;
h = 128;
w = 64;
step_size = 6;

all_pos_windows = zeros(50000, 5);
num_pos_windows = 1;
for i = 1:num_scale
    im = pyramids{i};
    features = features_pyramid{i};
    [bottomRightCol bottomRightRow d] = size(im);

    num_windows = ceil((bottomRightCol-h)/step_size * (bottomRightRow-w)/step_size*1.1);
    pos_windows = zeros(num_windows,5);
    ICF_test = zeros(num_windows,nFeatures);
    windows = zeros(num_windows, 5); % [x1, y1, x2, y2, score]
    fcount = 1;
    
    % this for loop scan the entire image and extract features for each sliding window
    for y = topLeftCol:step_size:bottomRightCol-h-step_size
        for x = topLeftRow:step_size:bottomRightRow-w-step_size
            window_feature = features(y:y+h-1, x:x+w-1, :);   
            window_feature(:,:,2:7) = window_feature(:,:,2:7) / window_feature(end,end,1);
            ICF_test(fcount, :) = rnd_sample_features(window_feature, feature_selection);
            windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
            fcount = fcount+1;
        end
        fcount
    end

    ICF_test = ICF_test(1:fcount, :);
    [predict_class, scores] = predict(ens5,ICF_test);
    pos_windows = windows( predict_class==1, :);
    pos_windows = ceil(pos_windows .* 2^(i-1)); % rescale back to origial image coordinates
    
    pos_scores = scores(predict_class==1, 2);
    pos_windows(:,5) = pos_scores;
      
    n_pos_windows_current_im = size(pos_windows,1);
    all_pos_windows(num_pos_windows:num_pos_windows+n_pos_windows_current_im-1, :) = pos_windows;
    num_pos_windows = num_pos_windows + n_pos_windows_current_im;
    
end


% select only windows with score > threshold
score_thr = 0; % for select the best sub-window
selected_pos_windows = all_pos_windows(all_pos_windows(:,5)> score_thr, :);
figure; 
subplot(2,2,1);showboxes(pyramids{1},  all_pos_windows);
subplot(2,2,2); showboxes(pyramids{1},  selected_pos_windows);

% My nms function
bestBBox = nms(selected_pos_windows,50,10);
subplot(2,2,3); showboxes(pyramids{1},  bestBBox);

% nms function by PDollar
bbs = bbNms(selected_pos_windows);
subplot(2,2,4); showboxes(pyramids{1}, bbs);

toc

% Elapsed time is 124.668783 seconds.
% Elapsed time is 670.433596 seconds. Step_size=3

















%% [[Fast]] Do sliding window detection on positive images with 2 pyramid per octave
%
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

tic
% read one test image with people
image = (imread([source, all_imagenames{5}]));
im = image(140:677, 238:520, :);
% im = image;
figure; imshow(im);

% Build gaussPyramid
num_scale = 5;
level_per_octave=2;
[pyramids, scale]=im_pyramid(im, level_per_octave, num_scale);
features_pyramid = cell(1, num_scale); 

for i = 1:num_scale
    features_pyramid{i} = gen_feature_channels(pyramids{i});
end

% for i = 1:num_scale*2-1
%     figure;
%     imshow(im_pyramid{i});
%     size(im_pyramid{i})
% end

% do sliding window
topLeftRow = 1;
topLeftCol = 1;
h = 128;
w = 64;
step_size = 6;

all_pos_windows = zeros(50000, 5);
num_pos_windows = 1;
for i = 1:num_scale
    im = pyramids{i};
    features = features_pyramid{i};
    [bottomRightCol bottomRightRow d] = size(im);

    num_windows = ceil((bottomRightCol-h)/step_size * (bottomRightRow-w)/step_size*1.1);
    pos_windows = zeros(num_windows,5);
    ICF_test = zeros(num_windows,nFeatures);
    windows = zeros(num_windows, 5); % [x1, y1, x2, y2, score]
    fcount = 1;
    
    % this for loop scan the entire image and extract features for each sliding window
    for y = topLeftCol:step_size:bottomRightCol-h-step_size
        for x = topLeftRow:step_size:bottomRightRow-w-step_size
            window_feature = features(y:y+h-1, x:x+w-1, :);   
            window_feature(:,:,2:7) = window_feature(:,:,2:7) / window_feature(end,end,1);
            ICF_test(fcount, :) = rnd_sample_features(window_feature, feature_selection);
            windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
            fcount = fcount+1;
        end
        fcount
    end

    ICF_test = ICF_test(1:fcount, :);
    [predict_class, scores] = predict(ens5,ICF_test);
    pos_windows = windows( predict_class==1, :);
    pos_windows = ceil(pos_windows ./scale(i)); % rescale back to origial image coordinates
    
    pos_scores = scores(predict_class==1, 2);
    pos_windows(:,5) = pos_scores;
      
    n_pos_windows_current_im = size(pos_windows,1);
    all_pos_windows(num_pos_windows:num_pos_windows+n_pos_windows_current_im-1, :) = pos_windows;
    num_pos_windows = num_pos_windows + n_pos_windows_current_im;
    
end


% select only windows with score > threshold
score_thr = 0; % for select the best sub-window
selected_pos_windows = all_pos_windows(all_pos_windows(:,5)> score_thr, :);
figure; 
subplot(2,2,1);showboxes(pyramids{1},  all_pos_windows);
subplot(2,2,2); showboxes(pyramids{1},  selected_pos_windows);

% My nms function
bestBBox = nms(selected_pos_windows,50,10);
subplot(2,2,3); showboxes(pyramids{1},  bestBBox);

% nms function by PDollar
bbs = bbNms(selected_pos_windows);
subplot(2,2,4); showboxes(pyramids{1}, bbs);

toc
























%% [[Fast]] Do sliding window detection on positive images with 5 pyramid with cascade
%
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

tic
% read one test image with people
image = (imread([source, all_imagenames{90}]));
% im = image(140:677, 238:520, :);
im = image;
figure; imshow(im);

% Build gaussPyramid
num_scale = 5;
level_per_octave=2;
[pyramids, scale]=im_pyramid(im, level_per_octave, num_scale);
features_pyramid = cell(1, num_scale); 

for i = 1:num_scale
    features_pyramid{i} = gen_feature_channels(pyramids{i});
end

% for i = 1:num_scale*2-1
%     figure;
%     imshow(im_pyramid{i});
%     size(im_pyramid{i})
% end

% do sliding window
topLeftRow = 1;
topLeftCol = 1;
h = 128;
w = 64;
step_size = 6;

all_pos_windows = zeros(50000, 5);
num_pos_windows = 1;
for i = 1:num_scale
    im = pyramids{i};
    features = features_pyramid{i};
    [bottomRightCol bottomRightRow d] = size(im);

    num_windows = ceil((bottomRightCol-h)/step_size * (bottomRightRow-w)/step_size*1.1);
    pos_windows = zeros(num_windows,5);
    ICF_test = zeros(num_windows,nFeatures);
    windows = zeros(num_windows, 5); % [x1, y1, x2, y2, score]
    fcount = 1;
    
    % this for loop scan the entire image and extract features for each sliding window
    for y = topLeftCol:step_size:bottomRightCol-h-step_size
        for x = topLeftRow:step_size:bottomRightRow-w-step_size
            window_feature = features(y:y+h-1, x:x+w-1, :);   
            window_feature(:,:,2:7) = window_feature(:,:,2:7) / window_feature(end,end,1);
            ICF_test(fcount, :) = rnd_sample_features(window_feature, feature_selection);
            windows(fcount, 1:4) = [x, y, x+w-1, y+h-1];
            fcount = fcount+1;
        end
        fcount
    end

    ICF_test = ICF_test(1:fcount, :);
%     [predict_class, scores] = predict(ens5,ICF_test);
    for j = 1:2
        [predict_class, scores] = predict(models{j},ICF_test);
        picked = scores(:,2)>thresholds(j);
        ICF_test = ICF_test(picked, :);
        windows = windows(picked, :);
    end

    [predict_class, scores] = predict(models{3},ICF_test);
    pos_windows = windows( predict_class==1, :);
    pos_windows = ceil(pos_windows ./scale(i)); % rescale back to origial image coordinates
    
    pos_scores = scores(predict_class==1, 2);
    pos_windows(:,5) = pos_scores;
      
    n_pos_windows_current_im = size(pos_windows,1);
    all_pos_windows(num_pos_windows:num_pos_windows+n_pos_windows_current_im-1, :) = pos_windows;
    num_pos_windows = num_pos_windows + n_pos_windows_current_im;
    
end


% select only windows with score > threshold
score_thr = 0; % for select the best sub-window
selected_pos_windows = all_pos_windows(all_pos_windows(:,5)> score_thr, :);
figure; 
subplot(2,2,1);showboxes(pyramids{1},  all_pos_windows);
subplot(2,2,2); showboxes(pyramids{1},  selected_pos_windows);

% My nms function
bestBBox = nms(selected_pos_windows,50,10);
subplot(2,2,3); showboxes(pyramids{1},  bestBBox);

% nms function by PDollar
bbs = bbNms(selected_pos_windows);
subplot(2,2,4); showboxes(pyramids{1}, bbs);

toc
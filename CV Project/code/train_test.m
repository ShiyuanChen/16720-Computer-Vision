% add path for tool box

% folder_names={dire.name};
% folder_names=folder_names(5:13);
% 
% for i = 1:length(folder_names)
%     addpath(fullfile('./toolbox/pdollar/', folder_names{i}));
% end
addpath(genpath('./toolbox/pdollar/'));
addpath(genpath('./toolbox/'));

%% training
% set up opts for training detector (see acfTrain)
opts=acfTrain(); opts.modelDs=[100 41]; opts.modelDsPad=[128 64];
opts.posGtDir=[dataDir 'train/posGt']; opts.nWeak=[32 128 512 2048];
opts.posImgDir=[dataDir 'train/pos']; opts.pJitter=struct('flip',1);
opts.negImgDir=[dataDir 'train/neg']; opts.pBoost.pTree.fracFtrs=1/16;
opts.pLoad={'squarify',{3,.41}}; opts.name='models/AcfInria';

pTree = opts.pBoost.pTree;
model = adaBoostTrain(ICF_neg, ICF, opts.pBoost);

Data = [ICF; ICF_neg];
label_pos = ones(2416,1);
label_neg = zeros(4560, 1);
label = [label_pos;label_neg];

ens = fitensemble(Data,label,'AdaBoostM1',100,'Tree');
rsLoss = resubLoss(ens,'Mode','Cumulative');

plot(rsLoss);
xlabel('Number of Learning Cycles');
ylabel('Resubstitution Loss');

%% extract feature and test for pos test data
nFeatures=1000;
source = '../INRIAPerson/test_64x128_H96/pos/';
target = '../dat/'; 
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

ypredict = zeros(1,l);
for i=1:l
    i
    ypredict(i) = predict(ens,ICF_test_pos(i,:));
end


%% Extrac featuers and test on randomly sampled negative data
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
    ypredict(i) = predict(ens,ICF_test_neg(i,:));
end


%% Do sliding window detection on positive images
source = '../INRIAPerson/Test/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);


tic
% read one test image with people
image = (imread([source, all_imagenames{1}]));
im = image(140:477, 138:320, :);
% im = image;
figure; imshow(im);
% do sliding window
topLeftRow = 1;
topLeftCol = 1;
[bottomRightCol bottomRightRow d] = size(im);
h = 128;
w = 64;
fcount = 1;
step_size = 6;
score_thr = 2.5; % for select the best sub-window

pos_windows = zeros(10000,5);
num_pos_windows = 0;
% this for loop scan the entire image and extract features for each sliding window
for y = topLeftCol:step_size:bottomRightCol-h
    for x = topLeftRow:step_size:bottomRightRow-w
        window = im(y:y+h-1, x:x+w-1, :);     
        ICF_test = integral_features(window, feature_selection);
        [predict_class, score] = predict(ens,ICF_test);
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
figure; showboxes(im,  selected_pos_windows);

% My nms function
bestBBox = nms(selected_pos_windows,100,10);
figure; showboxes(im,  bestBBox);

% nms function by PDollar
bbs = bbNms( selected_pos_windows);
figure; showboxes(im,  bbs);

toc


% gaussPyramid = vision.Pyramid('PyramidLevel', 2);
% J = step(gaussPyramid, im);
% figure, imshow(im); title('Original Image');
% figure, imshow(J); title('Reduced Image');


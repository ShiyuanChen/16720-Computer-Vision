% This script refines the normalized positive train data given by IRIA
% by shrink the positive window

% add tool box (including PDollar and others)
addpath(genpath('./toolbox/'));
% Initialize parameters
nFeatures = 5000;


%% Experiments to find the good value of padding
source = '../INRIAPerson/train_64x128_H96/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

padding=28;
figure;
for i=1:40
    image = (imread([source, all_imagenames{i}]));
    subplot(4,10,i);
    imshow(image(padding+1:size(image,1)-padding, padding+1:size(image,2)-padding, :));
end

% The padding size of 28 pixel seems good. 
% The according window size should be 104 X 40


%% Build feature_selection_small for new smaller training images
nFeatures = 5000;
h = 104;
w = 40;

layer=randi(10,nFeatures,1);
count=1;
x1=randi(w,nFeatures,1);
y1=randi(h,nFeatures,1);
x2=zeros(nFeatures,1);
y2=zeros(nFeatures,1);

while count <=nFeatures
    x2(count)=randi(w);
    y2(count)=randi(h);
    if abs((x1(count)-x2(count))*(y1(count)-y2(count)))>=25;
        if x1(count)>x2(count)
            temp=x1(count);
            x1(count)=x2(count);
            x2(count)=temp;
        end
        if y1(count)>y2(count)
            temp=y1(count);
            y1(count)=y2(count);
            y2(count)=temp;
        end   
        count=count+1;
    end
end
feature_selection_small = [x1, y1, x2, y2, layer];

%% Extract features for normalized positive samples
tic
source = '../INRIAPerson/train_64x128_H96/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

padding = 28;

ICF_small_pos = zeros(l, nFeatures);
for i=1:l
    i
    image = (imread([source, all_imagenames{i}]));
    integral_I = gen_feature_channels(image);
    
    % remove padding features
    [h w ~] = size(image);
    integral_I = integral_I(padding+1:h-padding, padding+1:w-padding, :);
    
    % normalize Ghist channles
    integral_I(:,:,2:7) = integral_I(:,:,2:7)/integral_I(end,end,1);
    
    ICF_small_pos(i, :) = rnd_sample_features(integral_I, feature_selection_small);
end
toc
% Elapsed time is 254.662787 seconds.


%% Extract features for negative samples with smaller size
% Randomly sample 8 negative windows per nagative image
tic
source = '../INRIAPerson/train_64x128_H96/neg/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

h = 104;
w = 40;
padding = 28;
num_per_im = 8;
ICF_small_neg = zeros(num_per_im*l,nFeatures);

for i=1:l
    i
    image = (imread([source, all_imagenames{i}]));
    x=randi(size(image,2)-w-padding+1,1,num_per_im);
    y=randi(size(image,1)-h+1-padding,1,num_per_im);
    
    for j = 1:num_per_im
        subwindow = image(y(j):y(j)+h+padding-1, x(j):x(j)+w+padding-1, :);
        integral_I = gen_feature_channels(subwindow);
        
        % remove padding features
        integral_I = integral_I(padding+1:h+padding, padding+1:w+padding, :);
        
        % normalize Ghist channles
        integral_I(:,:,2:7) = integral_I(:,:,2:7)/integral_I(end,end,1);

        ICF_small_neg((i-1)*num_per_im+j, :) = rnd_sample_features(integral_I, feature_selection_small);     
    end
end

toc
% Elapsed time is 500.042273 seconds.
% In total 7296 samples


%% Train cascade model
tic
% initialize parameters
nStages = 3;
nWeak = [30 100 500];

% Separate the negative training data into starters and backups
ICF_small_neg_starter = ICF_small_neg(1:4000, :);
ICF_neg_backup_cell = cell(2,1);
ICF_small_neg_backup{1} = ICF_small_neg(4001:5648,:);
ICF_small_neg_backup{2} = ICF_small_neg(5649:end,:);

% Training dataset
% Data_small = [ICF_small_pos(1:2000, :); ICF_small_neg_starter];
label_pos = ones(2000,1);
% label_neg = zeros(4000, 1);
% label = [label_pos;label_neg];

% Developement dataset, consist of 416 positive samples
dev_size = 416;
dev_data_small = ICF_small_pos(2001:2000+dev_size, :);
% dev_label_small = ones(dev_size,1);

% working negative data
working_neg_data = ICF_small_neg_starter;
neg_size = size(working_neg_data, 1);

% Start training
small_cascade_models = cell(1, nStages); % The cascade of models
thresholds = zeros(1, nStages); % The threshold to call a positive

for i = 1:nStages
    working_data = [ICF_small_pos(1:2000, :); working_neg_data];
    working_lable = [label_pos;zeros(neg_size,1)];
    small_cascade_models{i} = fitensemble(working_data,working_lable,'AdaBoostM1',nWeak(i),'Tree');
    
    % predict on development set
    [~, scores] = predict(small_cascade_models{i},dev_data_small);
    thresholds(i) = min(scores(:,2));
    
    % remove easy negatives
    if i < 3 % add in new negative data
        [~, scores] = predict(small_cascade_models{i},working_neg_data);
        working_neg_data = working_neg_data(scores(:,2)>thresholds(i), :);
        working_neg_data = [working_neg_data; ICF_small_neg_backup{i}];
    end
    
    neg_size = size(working_neg_data, 1);
    disp(size(working_neg_data,1));
end
toc

% Elapsed time is 1233.751802 seconds. ~20 min

% save('small_cascade_model.mat', 'small_cascade_models', 'feature_selection_small','nFeatures','padding','h','w','nWeak');
% v2
% Generate features with padding, and then discard when training

% add tool box (including PDollar and others)
addpath(genpath('./toolbox/'));

% Initialize parameters
nFeatures = 5000;

%% Generate random feature selection matrix
% layer=randi(10,nFeatures,1);
% x1=randi(size(channels{1},2),nFeatures,1);
% y1=randi(size(channels{1},1),nFeatures,1);
% x2=zeros(nFeatures,1);
% y2=zeros(nFeatures,1);
% count=1;
% while count <=nFeatures
%     x2(count)=randi(size(channels{1},2));
%     y2(count)=randi(size(channels{1},1));
%     if (x1(count)-x2(count))*(y1(count)-y2(count))>=25;
%         if x1(count)>x2(count)
%             temp=x1(count);
%             x1(count)=x2(count);
%             x2(count)=temp;
%             temp=y1(count);
%             y1(count)=y2(count);
%             y2(count)=temp;
%         end     
%         count=count+1;
%     end
% end
% feature_selection = [x1, y1, x2, y2, layer];


%% Extract features for normalized positive samples
tic
source = '../INRIAPerson/train_64x128_H96/pos/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

h = 128;
w = 64;
padding = 16;

ICF_pos = zeros(l, nFeatures);
for i=1:l
    i
    image = (imread([source, all_imagenames{i}]));
%     image=image(padding+1:h+padding, padding+1:w+padding, :);
    integral_I = gen_feature_channels(image);
    
    % remove padding features
    integral_I = integral_I(padding+1:h+padding, padding+1:w+padding, :);
    
    % normalize Ghist channles
    integral_I(:,:,2:7) = integral_I(:,:,2:7)/integral_I(end,end,1);
    
    ICF_pos(i, :) = rnd_sample_features(integral_I, feature_selection);
%     ICF_pos(i, :) = integral_features(image, feature_selection);
end
toc

% Elapsed time is 138.815417 seconds.
% Elapsed time is 243.363711 seconds. With new Ghist
% Elapsed time is 241.456174 seconds. with 5000 feature


%% Extract features for negative samples
% Randomly sample 5 negative windows per nagative image
tic
source = '../INRIAPerson/train_64x128_H96/neg/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

h = 128;
w = 64;
padding = 16;

num_per_im = 5;
ICF_neg = zeros(5*l,nFeatures);

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

        ICF_neg((i-1)*num_per_im+j, :) = rnd_sample_features(integral_I, feature_selection);
        
%         ICF_neg((i-1)*num_per_im+j, :) = integral_features(subwindow, feature_selection);
    end
end

toc
% Elapsed time is 336.835335 seconds. With new Ghist
% Elapsed time is 330.576765 seconds.



%% Train model
tic
Data = [ICF_pos; ICF_neg];
label_pos = ones(2416,1);
label_neg = zeros(4560, 1);
label = [label_pos;label_neg];

ens3 = fitensemble(Data,label,'AdaBoostM1',100,'Tree');
toc
% Elapsed time is 57.947777 seconds.

tic
ens4 = fitensemble(Data,label,'AdaBoostM1',1000,'Tree');
toc
% Elapsed time is 588.822243 seconds.
save('model_n1000.mat', 'ens4','feature_selection');


% With 5000 Features
tic
ens5 = fitensemble(Data,label,'AdaBoostM1',500,'Tree');
toc 
% Elapsed time is 1514.813645 seconds.
save('model_n500_f5000.mat', 'ens5','feature_selection');



figure;
rsLoss = resubLoss(ens4,'Mode','Cumulative');
plot(rsLoss);
xlabel('Number of Learning Cycles');
ylabel('Resubstitution Loss');


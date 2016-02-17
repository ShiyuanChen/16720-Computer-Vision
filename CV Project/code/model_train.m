% add tool box (including PDollar and others)
addpath(genpath('./toolbox/'));

% Initialize parameters
nFeatures = 1000;

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
    image=image(padding+1:h+padding, padding+1:w+padding, :);
    
    ICF_pos(i, :) = integral_features(image, feature_selection);
end
toc

% Elapsed time is 138.815417 seconds.
% Elapsed time is 132.743873 seconds. With new Ghist


%% Extract features for negative samples
% Randomly sample 5 negative windows per nagative image
tic
source = '../INRIAPerson/train_64x128_H96/neg/';
dirs=dir([source, '*.png']);
all_imagenames={dirs.name}';
l = length(all_imagenames);

h = 128;
w = 64;
num_per_im = 5;
ICF_neg = zeros(5*l,nFeatures);

for i=1:l
    i
    image = (imread([source, all_imagenames{i}]));
    x=randi(size(image,2)-w+1,1,num_per_im);
    y=randi(size(image,1)-h+1,1,num_per_im);
    
    for j = 1:num_per_im
        subwindow = image(y(j):y(j)+h-1, x(j):x(j)+w-1, :);
        ICF_neg((i-1)*num_per_im+j, :) = integral_features(subwindow, feature_selection);
    end
end

toc
% Elapsed time is 245.251043 seconds. With new Ghist



%% Train model
tic
Data = [ICF_pos; ICF_neg];
label_pos = ones(2416,1);
label_neg = zeros(4560, 1);
label = [label_pos;label_neg];

ens3 = fitensemble(Data,label,'AdaBoostM1',100,'Tree');
toc
% Elapsed time is 57.947777 seconds.


rsLoss = resubLoss(ens3,'Mode','Cumulative');
plot(rsLoss);
xlabel('Number of Learning Cycles');
ylabel('Resubstitution Loss');


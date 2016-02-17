
%numCores=4;
%try
%    fprintf('Closing any pools...\n');
%     matlabpool close; 
%    delete(gcp('nocreate'))
%catch ME
%    disp(ME.message);
%end
%fprintf('Starting a pool of workers with %d cores\n', numCores);
% matlabpool('local',numCores);
%parpool('local', numCores);

% add pdollar tool box for luv conversion
% addpath('./toolbox/pdollar/channels');
% savepath;

nFeatures=1000;
source = '../INRIAPerson/train_64x128_H96/neg/';
target = '../dat/'; 
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


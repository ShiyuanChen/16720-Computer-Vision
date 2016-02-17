clear;
addpath(genpath('../utils'));
addpath(genpath('../lib/esvm'));
load('../../data/bus_esvm.mat');
load('../../data/bus_data.mat');
source = '../../data/voc2007/';
k=35;
H=100;
W=100;
l=length(models);
params = esvm_get_default_params;
params.detect_levels_per_octave=3;

numCores = 4;
fprintf('Starting a pool of workers with %d cores\n', numCores);
parpool('local', numCores);

try
    fprintf('Closing any pools...\n');
    delete(gcp('nocreate'))
catch ME
    disp(ME.message);
end

parfor i=1:l
    I = imread([source, modelImageNames{i}]);
    gtbox=modelBoxes{i};
    I = imresize(I(gtbox(2):gtbox(4),gtbox(1):gtbox(3),:),[H,W]);
    %hog = vl_hog(single(I), cellSize, 'verbose');
    hog=extractHOGFeatures(I);
    hogfeatures(i,:)=hog;
end
fprintf('Closing the pool\n');
delete(gcp('nocreate'));

[idx,~,~,D] = kmeans(filterResponses,k,'EmptyAction','drop');
[~,inds] = min(D,[],1);
detectors=models(inds);
[boundingBoxes] = batchDetectImageESVM(gtImages, detectors, params);
[~,~,ap] = evalAP(gtBoxes,boundingBoxes);

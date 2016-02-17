function [boundingBoxes] = batchDetectImageESVM(imageNames, models, params)
addpath(genpath('../utils'));
addpath(genpath('../lib/esvm'));

source = '../../data/voc2007/';

l = length(imageNames);
boundingBoxes=cell(1,l);
for i=1:l
    I = imread([source, imageNames{i}]);
    [boundingBoxes{i}] = esvm_detect(I, models, params);
end

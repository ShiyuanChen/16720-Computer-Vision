clear;
addpath(genpath('../utils'));
addpath(genpath('../lib/esvm'));
load('../../data/bus_esvm.mat');
load('../../data/bus_data.mat');
params = esvm_get_default_params;
params.detect_levels_per_octave=3;
source = '../../data/voc2007/';
l = length(gtImages);
boundingBoxes=cell(1,l);
for i=1:l
    I = imread([source, gtImages{i}]);
    [boundingBoxes{i}] = esvm_detect(I, models, params);
    %if i==2
        %detectionBoxes=boundingBoxes{i};
        %bestBBox = nms(detectionBoxes(:,[1:4,end]),100,1);
        %figure; hold on; image(I); axis ij; hold on;
        %showboxes(I,  bestBBox);
    %end
end
[~,~,ap] = evalAP(gtBoxes,boundingBoxes);

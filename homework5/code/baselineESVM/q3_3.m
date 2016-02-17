clear;
addpath(genpath('../utils'));
addpath(genpath('../lib/esvm'));
load('../../data/bus_esvm.mat');
load('../../data/bus_data.mat');
params = esvm_get_default_params;
lpo=[3,5,10];
ap=zeros(3,1);
for i = 1:3
    params.detect_levels_per_octave=lpo(i);
    [boundingBoxes] = batchDetectImageESVM(gtImages, models, params);
    [~,~,ap(i)] = evalAP(gtBoxes,boundingBoxes);
end
fig=figure;
plot(lpo',ap);
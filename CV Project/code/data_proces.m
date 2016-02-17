% add pdollar tool box for luv conversion
addpath('./toolbox/pdollar/channels');
savepath;


imDir = fullfile('../INRIAPerson/train_64x128_H96','pos');
addpath(imDir);

fnames = dir(fullfile(imDir,'*.png'));
numfiles = length(fnames);
for i = 1 : 10
    I = imread(fnames(i).name);
%     size(I)

    % RGB to gray scale
    Igray = rgb2gray(I);
    
    % RGB to LUV 
    J = rgbConvert( I, 'luv');
end

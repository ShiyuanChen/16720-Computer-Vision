function [locs, desc] = briefLite(im)
levels=[-1,0,1,2,3,4];
k=sqrt(2);
sigma0=1;
th_contrast=0.03;
th_r=12;
[locs, GaussianPyramid] = DoGdetector(im, sigma0, k, levels, th_contrast,th_r);
load('testPattern.mat','compareX','compareY');
[locs,desc] = computeBrief(im, locs, levels, compareX, compareY);
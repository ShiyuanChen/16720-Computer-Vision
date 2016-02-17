
im{1}=imread('../results/ec8_1.jpg');
im{2}=imread('../results/ec8_2.jpg');
im{3}=imread('../results/ec8_3.jpg');
%im{4}=imread('../results/ec8_4.jpg');
%im{5}=imread('../results/ec8_5.jpg');
%im{6}=imread('../results/ec8_6.jpg');
%im{7}=imread('../results/ec8_7.jpg');

img=cell(7,1);
for i=1:3
    img{i}=im2double(rgb2gray(im{i}));
end

nIter = 20;
tol = 10;
source1=img{1};
im1=im{1};
for i=2:3
    source2=img{i};
    im2=im{i};
    [locs1, desc1] = briefLite(source1);
    [locs2, desc2] = briefLite(source2);
    [matches] = briefMatch(desc1, desc2);
    [bestH] = ransacH(matches, locs1, locs2, nIter, tol);
    im1 = imageStitching_noClip(im1, im2, bestH);
    source1=im2double(rgb2gray(im1));
end
imwrite(im1, '../results/ec8_pan.jpg');



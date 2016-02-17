function im3 = generatePanorama(im1, im2)

img1 = im2double(im1);
if size(img1,3)==3
    img1= rgb2gray(img1);
end
img2 = im2double(im2);
if size(img2,3)==3
    img2= rgb2gray(img2);
end
nIter = 17;
tol = 10;
[locs1, desc1] = briefLite(img1);
[locs2, desc2] = briefLite(img2);
[matches] = briefMatch(desc1, desc2);
[bestH] = ransacH(matches, locs1, locs2, nIter, tol);
im3 = imageStitching_noClip(im1, im2, bestH);
imwrite(im3, '../results/q7_2.jpg');

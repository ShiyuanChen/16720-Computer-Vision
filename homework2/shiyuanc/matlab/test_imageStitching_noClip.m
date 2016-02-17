
testMatch;
img1=imread('../data/incline_L.png');
img2=imread('../data/incline_R.png');
p1=transpose(locs1(matches(:,1),1:2));
p2=transpose(locs2(matches(:,2),1:2));
H2to1=computeH(p1,p2);
[panoImg] = imageStitching_noClip(img1, img2, H2to1);
idx=[768,432,165,756,950,817];
H2to1Manual=computeH(p1(:,idx),p2(:,idx));
[panoImgM] = imageStitching_noClip(img1, img2, H2to1Manual);
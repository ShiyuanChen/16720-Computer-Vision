function [panoImg] = imageStitching_noClip(img1, img2, H2to1)

im1 = im2double(img1);
if size(im1,3)==3
    im1= rgb2gray(im1);
end
im2 = im2double(img2);
if size(im2,3)==3
    im2= rgb2gray(im2);
end
r=1.0;
out_size=[0,0];
im2top=H2to1*[size(im2,2);1;1];
im2top=im2top./im2top(3);
im2bottom=H2to1*[size(im2,2);size(im2,1);1];
im2bottom=im2bottom./im2bottom(3);
out_size(2)=round(r*max(size(im1,2),max(im2top(1),im2bottom(1))));
%out_size(2)=round(r*max(im2top(1),im2bottom(1)));
M=[r,0,0;0,r,r*(1-im2top(2));0,0,1];
out_size(1)=round(r*((1-im2top(2))+im2bottom(2)));

warp_im1=warpH(img1, M, out_size);
warp_im2=warpH(img2, M*H2to1, out_size);
warp_im1=double(warp_im1);
warp_im2=double(warp_im2);

mask1 = zeros(size(im1,1), size(im1,2));
mask1(1,:) = 1; mask1(end,:) = 1; mask1(:,1) = 1; mask1(:,end) = 1;
mask1 = bwdist(mask1, 'city');
mask1 = mask1/max(mask1(:));
mask2 = zeros(size(im2,1), size(im2,2));
mask2(1,:) = 1; mask2(end,:) = 1; mask2(:,1) = 1; mask2(:,end) = 1;
mask2 = bwdist(mask2, 'city');
mask2 = mask2/max(mask2(:));

temp1=warpH(mask1,M,out_size);
mask1=zeros(out_size(1),out_size(2),3);
mask1(:,:,:)=repmat(temp1,1,1,3); 

temp2=warpH(mask2,M*H2to1,out_size);
mask2=zeros(out_size(1),out_size(2),3);
mask2(:,:,:)=repmat(temp2,1,1,3);

blend1=double((mask1 ~= 0) & (mask2 == 0));
blend2=double((mask2 ~= 0) & (mask1 == 0));
fade1=double(((mask1 ~= 0) & (mask2 ~= 0)).*(mask1./(mask1+mask2)));
fade2=double(((mask1 ~= 0) & (mask2 ~= 0)).*(mask2./(mask1+mask2)));

panoImg=uint8(blend1.*warp_im1 + blend2.*warp_im2 + fade1.*(warp_im1.*(1-mask2)+warp_im2.*mask2)+fade2.*(warp_im1.*mask1+warp_im2.*(1-mask1)));
%imwrite(panoImg, '../results/q6_2_pan_M.jpg');
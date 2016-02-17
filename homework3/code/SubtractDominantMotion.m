function mask = SubtractDominantMotion(image1, image2)
threshhold=20;
M = LucasKanadeAffine(image1, image2);
[c,r]=meshgrid(1:size(image2,2),1:size(image2,1));
M_inv=inv(M);
Imx=M_inv(1,1).*c(:,:)+M_inv(1,2).*r(:,:)+M_inv(1,3);
Imy=M_inv(2,1).*c(:,:)+M_inv(2,2).*r(:,:)+M_inv(2,3);
Imap(:,:)=uint8((Imx(:,:)>=1) & (Imx(:,:)<=size(image1,2)) & (Imy(:,:)>=1) & (Imy(:,:)<=size(image1,1)));
out_size(:,:)=size(image2);
fill_value=0;
tform = maketform( 'projective', M'); 
warp_im = imtransform( image1, tform, 'bilinear', 'XData',[1 out_size(2)], 'YData', [1 out_size(1)], 'Size', out_size(1:2), 'FillValues', fill_value*ones(size(image1,3),1));
diff_im=(image2-warp_im).*Imap;
mask=diff_im>threshhold;
mask=imdilate(mask,strel('disk',4));
mask= bwareaopen(mask, 100);

%mask=imerode(mask,strel('disk',1));
%mask= bwareaopen(mask, 1);
%mask=imdilate(mask,strel('disk',7));
load('../data/aerialseq.mat','frames');
p=zeros(6,size(frames,3));
p(:,1)=[0;0;0;0;0;0];
M=zeros(3,3);
It=frames(:,:,1);
It1=frames(:,:,2);
for i=1:1
    M = LucasKanadeAffine(It, It1);
end
w=M(1:2,1:3);
out_size=size(It);
warp_im2=warpH(It, M, out_size);
figure;
imshow(It1-It);
figure;
imshow(It1-warp_im2);

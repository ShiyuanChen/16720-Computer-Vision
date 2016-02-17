clear;
load('../data/aerialseq.mat','frames');
imsize=size(frames(:,:,1));
mask=zeros(imsize(1),imsize(2),4);
mask=logical(mask);
for i=30:30:120
    mask(:,:,i/30) = SubtractDominantMotion(frames(:,:,i), frames(:,:,i+1));
    fig=figure;
    mask_p=zeros(size(mask,1),size(mask,2),3);
    mask_p(:,:,1)=255.*mask(:,:,i/30);
    mask_p(:,:,3)=255.*mask(:,:,i/30);
    mask_p(:,:,2)=0.*mask(:,:,i/30);
    output=imfuse(frames(:,:,i+1),mask_p,'blend');
    imshow(output);
    set(gca,'position',[0 0 1 1]);
    print(fig,['q3_',num2str(i)],'-djpeg','-r150');
end


clear;
load('../data/sylvseq.mat','frames');
load('../data/sylvbases.mat','bases');
p=zeros(2,size(frames,3));
p(:,1)=[0;0];
rects=zeros(size(frames,3),4);
rects(1,:)=[102,62,156,108];
rects2=zeros(size(frames,3),4);
rects2(1,:)=[102,62,156,108];
for i=1:size(frames,3)-1
    [p(1,i+1),p(2,i+1)] = LucasKanadeBasis(frames(:,:,i), frames(:,:,i+1), rects(i,:), bases);
    p(:,i+1)=p(:,i+1)+p(:,i);
    rects(i+1,:)=[102+p(1,i+1),62+p(2,i+1),156+p(1,i+1),108+p(2,i+1)];
end
p=zeros(2,size(frames,3));
p(:,1)=[0;0];
for i=1:size(frames,3)-1
    [p(1,i+1),p(2,i+1)] = LucasKanade(frames(:,:,i), frames(:,:,i+1), rects2(i,:));
    p(:,i+1)=p(:,i+1)+p(:,i);
    rects2(i+1,:)=[102+p(1,i+1),62+p(2,i+1),156+p(1,i+1),108+p(2,i+1)];
end
save('sylvseqrects.mat','rects');
n=[1,200,300,350,400];
for k =1:5
    i=n(k);
    fig=figure;
    imshow(frames(:,:,i));
    hold;
    rectangle('Position',[rects2(i,1),rects2(i,2),rects2(i,3)-rects2(i,1),rects2(i,4)-rects2(i,2)],'LineWidth',3,'EdgeColor','g');
    rectangle('Position',[rects(i,1),rects(i,2),rects(i,3)-rects(i,1),rects(i,4)-rects(i,2)],'LineWidth',3,'EdgeColor','y');
    set(gca,'position',[0 0 1 1]);
    print(fig,['q2_',num2str(i)],'-djpeg','-r150');
end
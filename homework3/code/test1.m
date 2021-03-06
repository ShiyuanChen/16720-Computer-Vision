clear;
load('../data/sylvextseq.mat','frames');
load('../data/sylvextbases.mat','bases');
p=zeros(2,size(frames,3));
p(:,1)=[0;0];
rects=zeros(size(frames,3),4);
rects(1,:)=[122, 59, 169, 104];
rects2=zeros(size(frames,3),4);
rects2(1,:)=[122, 59, 169, 104];
for i=1:size(frames,3)-1
    [p(1,i+1),p(2,i+1)] = LucasKanadeBasis(frames(:,:,i), frames(:,:,i+1), rects(i,:), bases);
    p(:,i+1)=p(:,i+1)+p(:,i);
    rects(i+1,:)=[122+p(1,i+1),59+p(2,i+1),169+p(1,i+1),104+p(2,i+1)];
end
p=zeros(2,size(frames,3));
p(:,1)=[0;0];
for i=1:size(frames,3)-1
    [p(1,i+1),p(2,i+1)] = LucasKanade(frames(:,:,i), frames(:,:,i+1), rects2(i,:));
    p(:,i+1)=p(:,i+1)+p(:,i);
    rects2(i+1,:)=[122+p(1,i+1),59+p(2,i+1),169+p(1,i+1),104+p(2,i+1)];
end
%save('sylvseqrects.mat','rects');
n=[1,200,300,350,400,600,800,1000,1200,1300];
for k =1:10
    i=n(k);
    fig=figure;
    imshow(frames(:,:,i));
    hold;
    rectangle('Position',[rects2(i,1),rects2(i,2),rects2(i,3)-rects2(i,1),rects2(i,4)-rects2(i,2)],'LineWidth',3,'EdgeColor','g');
    rectangle('Position',[rects(i,1),rects(i,2),rects(i,3)-rects(i,1),rects(i,4)-rects(i,2)],'LineWidth',3,'EdgeColor','y');
    set(gca,'position',[0 0 1 1]);
    print(fig,['q2_',num2str(i),'_ext'],'-djpeg','-r150');
end
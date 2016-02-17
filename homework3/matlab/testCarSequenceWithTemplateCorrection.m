clear;
load('../data/carseq.mat','frames');
p=zeros(2,size(frames,3));
dp=zeros(2,size(frames,3));
p(:,1)=[0;0];
dp(:,1)=[0,0];
rects=zeros(size(frames,3),4);
rects(1,:)=[60,117,146,152];
for i=1:size(frames,3)-1
    [dp(1,i+1),dp(2,i+1)] = LucasKanadeWithTemplateCorrection(frames(:,:,i), frames(:,:,i+1), rects(i,:),dp(:,i));
    p(:,i+1)=dp(:,i+1)+p(:,i);
    [tempu,tempv] = LucasKanadeWithTemplateCorrection(frames(:,:,1), frames(:,:,i+1), rects(1,:),p(:,i+1));
    if norm([tempu;tempv]-p(:,i+1))<5
        p(:,i+1)=[tempu;tempv];
    else
        p(:,i+1)=p(:,i);
    end
    rects(i+1,:)=[60+p(1,i+1),117+p(2,i+1),146+p(1,i+1),152+p(2,i+1)];
end
save('carseqrects-wcrt.mat','rects');
%fig=figure;
%imshow(frames(:,:,1));
%hold;
%rectangle('Position',[rects(1,1),rects(1,2),rects(1,3)-rects(1,1),rects(1,4)-rects(1,2)],'LineWidth',3,'EdgeColor','y');
%set(gca,'position',[0 0 1 1]);
%print(fig,'q1_1_wcrt','-djpeg','-r150');
%for i =100:100:400
%    fig=figure;
%    imshow(frames(:,:,i));
%    hold;
%    rectangle('Position',[rects(i,1),rects(i,2),rects(i,3)-rects(i,1),rects(i,4)-rects(i,2)],'LineWidth',3,'EdgeColor','y');
%    set(gca,'position',[0 0 1 1]);
%    print(fig,['q1_',num2str(i),'_wcrt'],'-djpeg','-r150');
%end
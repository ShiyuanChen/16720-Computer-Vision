
load('../data/sylvseq.mat','frames');
p=zeros(2,size(frames,3));
dp=zeros(2,size(frames,3));
p(:,1)=[0;0];
dp(:,1)=[0,0];
for i=1:size(frames,3)-1
    [dp(1,i+1),dp(2,i+1)] = LucasKanadeWithTemplateCorrection(frames(:,:,i), frames(:,:,i+1), [102+p(1,i); 62+p(2,i); 156+p(1,i); 108+p(2,i)],dp(:,i));
    p(:,i+1)=dp(:,i+1)+p(:,i);
    [tempu,tempv] = LucasKanadeWithTemplateCorrection(frames(:,:,1), frames(:,:,i+1), [102; 62; 156; 108],p(:,i+1));
    if norm([tempu;tempv]-p(:,i+1))<5
        p(:,i+1)=[tempu;tempv];
    else
        p(:,i+1)=p(:,i);
    end
end
figure;
    imshow(frames(:,:,1));
    hold;
    plot([102+p(1,1),156+p(1,1),156+p(1,1),102+p(1,1),102+p(1,1)] ,[62+p(2,1),62+p(2,1),108+p(2,1),108+p(2,1),62+p(2,1)],'y');
for i =1:5:400
    figure;
    imshow(frames(:,:,i));
    hold;
    plot([102+p(1,i),156+p(1,i),156+p(1,i),102+p(1,i),102+p(1,i)] ,[62+p(2,i),62+p(2,i),108+p(2,i),108+p(2,i),62+p(2,i)],'y');
end
%imshow(frames(:,:,1));
%hold;
%plot([60,146,146,60,60] ,[117,117,152,152,117],'g');
function M = LucasKanadeAffine(It, It1)

[c,r]=meshgrid(1:size(It,2),1:size(It,1));
[c1,r1]=meshgrid(1:size(It1,2),1:size(It1,1));
It=im2double(It);
It1=im2double(It1);
[Tx,Ty]=gradient(It);

SD(:,:,1)=Tx.*c;
SD(:,:,2)=Tx.*r;
SD(:,:,3)=Tx;
SD(:,:,4)=Ty.*c;
SD(:,:,5)=Ty.*r;
SD(:,:,6)=Ty;
p=zeros(6,1);

dp=[inf;inf;inf;inf;inf;inf];
Tmap=zeros(size(It,1),size(It,2));

while norm(dp)>0.01
    M=[1+p(1),p(2),p(3);p(4),1+p(5),p(6);0,0,1];
    w=M(1:2,1:3);
    Twx=w(1,1).*c(:,:)+w(1,2).*r(:,:)+w(1,3);
    Twy=w(2,1).*c(:,:)+w(2,2).*r(:,:)+w(2,3);
    Tmap(:,:)=(Twx(:,:)>=1) & (Twx(:,:)<=size(It1,2)) & (Twy(:,:)>=1) & (Twy(:,:)<=size(It1,1));
    for i=1:6
        for j=1:6
            H(i,j)=sum(sum(SD(:,:,i).*SD(:,:,j).*Tmap(:,:)));
        end
    end
    [row,col,I_x]=find(Twx(:,:).*Tmap(:,:));
    [row,col,I_y]=find(Twy(:,:).*Tmap(:,:));
    ind=sub2ind(size(It1),row,col);
    Iw_v=interp2(c1,r1,It1(:,:),I_x,I_y);
    Iw=zeros(size(It1,1),size(It1,2));
    Iw(ind)=Iw_v;
    DIt=Iw(:,:)-Tmap(:,:).*It(:,:);
    for i=1:6
        b(i,1)=sum(sum(SD(:,:,i).*DIt(:,:)));
    end
    dp=H\b;
    %dw=[1+dp(1),dp(2),dp(3);dp(4),1+dp(5),dp(6)];
    dM_inv=inv([1+dp(1),dp(2),dp(3);dp(4),1+dp(5),dp(6);0,0,1]);
    dw_inv=dM_inv(1:2,1:3);
    p(:)=[p(1)+dw_inv(1,1)-1+p(1)*(dw_inv(1,1)-1)+p(2)*dw_inv(2,1);...
        p(2)+dw_inv(1,2)+p(1)*dw_inv(1,2)+p(2)*(dw_inv(2,2)-1);...
        p(3)+dw_inv(1,3)+p(1)*dw_inv(1,3)+p(2)*dw_inv(2,3);...
        p(4)+dw_inv(2,1)+p(4)*(dw_inv(1,1)-1)+p(5)*dw_inv(2,1);...
        p(5)+dw_inv(2,2)-1+p(4)*dw_inv(1,2)+p(5)*(dw_inv(2,2)-1);...
        p(6)+dw_inv(2,3)+p(4)*dw_inv(1,3)+p(5)*dw_inv(2,3)];
end
M=[1+p(1),p(2),p(3);p(4),1+p(5),p(6);0,0,1];
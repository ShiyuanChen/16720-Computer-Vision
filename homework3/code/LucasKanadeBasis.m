function [u,v] = LucasKanadeBasis(It, It1, rect, bases)

It=im2double(It);
It1=im2double(It1);
[Tx,Ty]=gradient(It);
%[Ix1,Iy1]=gradient(It1);
[c,r]=meshgrid(floor(rect(1)):ceil(rect(3)),floor(rect(2)):ceil(rect(4)));
[c1,r1]=meshgrid(rect(1):rect(3),rect(2):rect(4));
T=interp2(c,r,It(floor(rect(2)):ceil(rect(4)),floor(rect(1)):ceil(rect(3))),c1,r1);
Tx=interp2(c,r,Tx(floor(rect(2)):ceil(rect(4)),floor(rect(1)):ceil(rect(3))),c1,r1);
Ty=interp2(c,r,Ty(floor(rect(2)):ceil(rect(4)),floor(rect(1)):ceil(rect(3))),c1,r1);

m=size(bases,3);
Tx1=repmat(Tx,1,1,m);
Ty1=repmat(Ty,1,1,m);
SDx=Tx-sum(repmat(sum(sum(bases(:,:,:).*Tx1,1),2),size(bases,1),size(bases,2),1).*bases(:,:,:),3);
SDy=Ty-sum(repmat(sum(sum(bases(:,:,:).*Ty1,1),2),size(bases,1),size(bases,2),1).*bases(:,:,:),3);
H(:,:)=[sum(sum(SDx.^2)),sum(sum(SDx.*SDy));sum(sum(SDx.*SDy)),sum(sum(SDy.^2))];
u=0;
v=0;

du=inf;
dv=inf;
while norm([du;dv])>0.01
    row1=rect(2)+v;
    col1=rect(1)+u;
    row2=rect(4)+v;
    col2=rect(3)+u;
    [c,r]=meshgrid(floor(col1):ceil(col2),floor(row1):ceil(row2));
    [c1,r1]=meshgrid(col1:col2,row1:row2);
    Itp=interp2(c,r,It1(floor(row1):ceil(row2),floor(col1):ceil(col2)),c1,r1)-T;
    b=[sum(sum(SDx.*Itp));sum(sum(SDy.*Itp))];
    temp=H\b;
    du=temp(1);
    dv=temp(2);
    
    u=u-du;
    v=v-dv;
end



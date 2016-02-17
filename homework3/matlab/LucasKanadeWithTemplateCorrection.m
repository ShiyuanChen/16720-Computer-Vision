function [u,v] = LucasKanadeWithTemplateCorrection(It, It1, rect, p0)

It=im2double(It);
It1=im2double(It1);
%[Ix,Iy]=gradient(It);
[Ix1,Iy1]=gradient(It1);

[c,r]=meshgrid(floor(rect(1)):ceil(rect(3)),floor(rect(2)):ceil(rect(4)));
[c1,r1]=meshgrid(rect(1):rect(3),rect(2):rect(4));
    
It_w=interp2(c,r,It(floor(rect(2)):ceil(rect(4)),floor(rect(1)):ceil(rect(3))),c1,r1);

u=p0(1);
v=p0(2);

du=inf;
dv=inf;
A=zeros(2,2);
while norm([du;dv])>0.01
    row1=rect(2)+v;
    col1=rect(1)+u;
    row2=rect(4)+v;
    col2=rect(3)+u;
    [c,r]=meshgrid(floor(col1):ceil(col2),floor(row1):ceil(row2));
    [c1,r1]=meshgrid(col1:col2,row1:row2);
    Ixp=interp2(c,r,Ix1(floor(row1):ceil(row2),floor(col1):ceil(col2)),c1,r1);
    Iyp=interp2(c,r,Iy1(floor(row1):ceil(row2),floor(col1):ceil(col2)),c1,r1);
    Itp=interp2(c,r,It1(floor(row1):ceil(row2),floor(col1):ceil(col2)),c1,r1)-It_w;
    A(:,:)=[sum(sum(Ixp.^2)),sum(sum(Ixp.*Iyp));sum(sum(Ixp.*Iyp)),sum(sum(Iyp.^2))];
    b=-[sum(sum(Ixp.*Itp));sum(sum(Iyp.*Itp))];
    temp=A\b;
    du=temp(1);
    dv=temp(2);
    u=u+du;
    v=v+dv;
end
    

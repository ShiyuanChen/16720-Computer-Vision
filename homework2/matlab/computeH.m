function H2to1=computeH(p1,p2)

N=size(p1,2);
A=zeros(2*N,9);
for i=1:size(p1,2)
    A(2*i-1,:)=[p2(1,i),p2(2,i),1,0,0,0,-p2(1,i)*p1(1,i),-p2(2,i)*p1(1,i),-p1(1,i)];
    A(2*i,:)=[0,0,0,p2(1,i),p2(2,i),1,-p2(1,i)*p1(2,i),-p2(2,i)*p1(2,i),-p1(2,i)];
end
[~,~,V] = svd(A);
h=V(:,9);
H2to1=transpose(reshape(h,[3,3]));
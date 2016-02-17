function [ F ] = sevenpoint( pts1, pts2, M )
% sevenpoint:
%   pts1 - Nx2 matrix of (x,y) coordinates
%   pts2 - Nx2 matrix of (x,y) coordinates
%   M    - max (imwidth, imheight)

% Q2.2 - Todo:
%     Implement the eightpoint algorithm
%     Generate a matrix F from some '../data/some_corresp.mat'
%     Save recovered F (either 1 or 3 in cell), M, pts1, pts2 to q2_2.mat

%     Write recovered F and display the output of displayEpipolarF in your writeup
N=size(pts1,1);
T=[1.0/M,0,0;0,1.0/M,0;0,0,1];
norm_p1=[pts1,ones(N,1)]*T';
norm_p2=[pts2,ones(N,1)]*T';

U = [ repmat(norm_p2(:,1),1,3) .* norm_p1, repmat(norm_p2(:,2),1,3) .* norm_p1, norm_p1(:,1:3)];
[~,~,V] = svd(U);
F_1 = reshape(V(:,end-1),3,3)';
F_2 = reshape(V(:,end),3,3)';
syms h;
y=det(h.*F_1+(1-h).*F_2);
x=double(solve(y));
if x(1)==x(2)
    F=cell(1);
    F_n = refineF((x(1).*F_1+(1-x(1)).*F_2),norm_p1(:,1:2),norm_p2(:,1:2));
    F{1}=T'*F_n*T;
else
    F=cell(3,1);
    F_n1 = refineF((x(1).*F_1+(1-x(1)).*F_2),norm_p1(:,1:2),norm_p2(:,1:2));
    F_n2 = refineF((x(2).*F_1+(1-x(2)).*F_2),norm_p1(:,1:2),norm_p2(:,1:2));
    F_n3 = refineF((x(3).*F_1+(1-x(3)).*F_2),norm_p1(:,1:2),norm_p2(:,1:2));
    F{1}=T'*F_n1*T;
    F{2}=T'*F_n2*T;
    F{3}=T'*F_n3*T;
end
end


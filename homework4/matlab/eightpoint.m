function [ F ] = eightpoint( pts1, pts2, M )
% eightpoint:
%   pts1 - Nx2 matrix of (x,y) coordinates
%   pts2 - Nx2 matrix of (x,y) coordinates
%   M    - max (imwidth, imheight)

% Q2.1 - Todo:
%     Implement the eightpoint algorithm
%     Generate a matrix F from some '../data/some_corresp.mat'
%     Save F, M, pts1, pts2 to q2_1.mat

%     Write F and display the output of displayEpipolarF in your writeup
N=size(pts1,1);
T=[1.0/M,0,0;0,1.0/M,0;0,0,1];
norm_p1=[pts1,ones(N,1)]*T';
norm_p2=[pts2,ones(N,1)]*T';

U = [ repmat(norm_p2(:,1),1,3) .* norm_p1, repmat(norm_p2(:,2),1,3) .* norm_p1, norm_p1(:,1:3)];
[~,~,V] = svd(U);
F_n = reshape(V(:,end),3,3)';

[w,s,v] = svd(F_n);
F_n = w*diag([s(1) s(5) 0])*(v');
F_n = refineF(F_n,norm_p1(:,1:2),norm_p2(:,1:2));
F= T'*F_n*T;

end


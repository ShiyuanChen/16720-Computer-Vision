function [ P, error ] = triangulate( M1, p1, M2, p2 )
% triangulate:
%       M1 - 3x4 Camera Matrix 1
%       p1 - Nx2 set of points
%       M2 - 3x4 Camera Matrix 2
%       p2 - Nx2 set of points

% Q2.4 - Todo:
%       Implement a triangulation algorithm to compute the 3d locations
%       See Szeliski Chapter 7 for ideas
%
N=size(p1,1);
p1_h=[p1,ones(N,1)];
p2_h=[p2,ones(N,1)];
P = ones(N,4);
for i = 1 : N
	A =[p1_h(i,1)*M1(3,:) - M1(1,:);
        p1_h(i,2)*M1(3,:) - M1(2,:);
        p2_h(i,1)*M2(3,:) - M2(1,:);
        p2_h(i,2)*M2(3,:) - M2(2,:)];    
	[u,s,v] = svd(A);
	P(i,:) = v(:,end)';
end
P = P./repmat(P(:,4),1,4);
p1_hat=(M1*P')';
p2_hat=(M2*P')';
P=P(:,1:3);
error=sum(sum((p1-p1_hat(:,1:2)).^2,2)+sum((p2-p2_hat(:,1:2)).^2,2),1);
end


% Q2.5 - Todo:
%       1. Load point correspondences
%       2. Obtain the correct M2
%       4. Save the correct M2, p1, p2, R and P to q2_5.mat
clear;
load('../data/some_corresp.mat');
load('../data/intrinsics.mat');
im1=imread('../data/im1.png');
im2=imread('../data/im2.png');
M=max(size(im1,1),size(im1,2));
[ F ] = eightpoint( pts1, pts2, M );
[ E ] = essentialMatrix( F, K1, K2 );
[M2s] = camera2(E);
M1=K1*[eye(3),zeros(3,1)];
for k=1:4
    M2=K2*M2s(:,:,k);
    [ P, error ] = triangulate( M1, pts1, M2, pts2 );
    if(size(find(P(:,3)>0),1)==size(P,1))
        break;
    end
end
p1=pts1;
p2=pts2;
save('q2_5.mat','M2','p1','p2','P');
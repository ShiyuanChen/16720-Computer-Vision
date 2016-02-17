function [ F ] = ransacF( pts1, pts2, M )
% ransacF:
%   pts1 - Nx2 matrix of (x,y) coordinates
%   pts2 - Nx2 matrix of (x,y) coordinates
%   M    - max (imwidth, imheight)

% Q2.X - Extra Credit:
%     Implement RANSAC
%     Generate a matrix F from some '../data/some_corresp_noisy.mat'
%          - using eightpoint
%          - using ransac

%     In your writeup, describe your algorith, how you determined which
%     points are inliers, and any other optimizations you made
nIter=33;
N=size(pts1,1);
tol = 10;
bestInNum=0;
distance=zeros(N,1);
for i=1:nIter
    idx=randperm(N,7);
    sample1=pts1(idx,:);
    sample2=pts2(idx,:);
    tempF = sevenpoint( sample1, sample2, M );
    for k=1:size(tempF,1);
        for j=1:N
            v=[pts1(j,1);pts1(j,2);1];
            l=tempF{k}*v;
            s = sqrt(l(1)^2+l(2)^2);
            l = l/s;
            distance(j)=abs(l(1)*pts2(j,1)+l(2)*pts2(j,2)+l(3));
        end
        inlierNum=length(find(distance<=tol));
        if inlierNum > bestInNum
            F=tempF{k};
            bestInNum=inlierNum;
        end
    end
end

end


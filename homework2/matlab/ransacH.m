function [bestH] = ransacH(matches, locs1, locs2, nIter, tol)
p1=transpose(locs1(matches(:,1),1:2));
p2=transpose(locs2(matches(:,2),1:2));
nMatch=size(p1,2);
p2to1=zeros(2,nMatch);
inlierRatio=0.3;
idx=randperm(nMatch, 4);
sample1=p1(:,idx);
sample2=p2(:,idx);
H2to1=computeH(sample1,sample2);
bestH=H2to1;
bestInNum=0;
for i=1:nIter
    sample1=p1(:,idx);
    sample2=p2(:,idx);
    H2to1=computeH(sample1,sample2);
    tempp2=H2to1*[p2;ones(1,nMatch)];
    p2to1(1,:)=tempp2(1,:)./tempp2(3,:);
    p2to1(2,:)=tempp2(2,:)./tempp2(3,:);
    distance=sqrt(sum((p1-p2to1).^2));
    inlierIdx=find(distance<=tol);
    inlierNum=length(inlierIdx);
    if inlierNum > bestInNum
        bestH=H2to1;
        bestInNum=inlierNum;
        bestIdx=inlierIdx;
    end
    if inlierNum>=round(inlierRatio*nMatch)
        idx=inlierIdx;
    else
        idx=randperm(nMatch, 4);
    end
end